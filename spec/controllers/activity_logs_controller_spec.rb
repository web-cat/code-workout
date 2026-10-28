require 'spec_helper'

RSpec.describe ActivityLogsController, type: :controller do
  let(:admin_role) do
    GlobalRole.find_by(id: GlobalRole::ADMINISTRATOR_ID) ||
      GlobalRole.create!(id: GlobalRole::ADMINISTRATOR_ID, name: 'Administrator', can_edit_system_configuration: true, can_manage_all_courses: true, builtin: true)
  end
  let(:student_role) do
    GlobalRole.find_by(id: GlobalRole::REGULAR_USER_ID) ||
      GlobalRole.create!(id: GlobalRole::REGULAR_USER_ID, name: 'Regular User', can_edit_system_configuration: false, can_manage_all_courses: false, builtin: true)
  end

  let(:admin) { FactoryBot.create(:user, global_role: admin_role) }
  let(:student) { FactoryBot.create(:user, first_name: 'Alice', last_name: 'Smith', email: 'alice@example.edu', global_role: student_role) }
  let(:other_student) { FactoryBot.create(:user, first_name: 'Bob', last_name: 'Jones', email: 'bob@example.edu', global_role: student_role) }

  let(:workout_gym) { FactoryBot.create(:workout, name: 'Gym Recursion Practice') }
  let(:workout_course) { FactoryBot.create(:workout, name: 'Midterm Exam Workout') }

  let(:organization) do
    Organization.find_by(abbreviation: 'VT') ||
      FactoryBot.create(:organization, abbreviation: "VT_#{SecureRandom.hex(3)}")
  end
  let(:course) { FactoryBot.create(:course, organization: organization) }
  let(:term) { Term.find_by(season: 100, year: Date.today.year) || FactoryBot.create(:term100) }
  let(:course_offering) { FactoryBot.create(:course_offering, course: course, term: term, label: 'Section 1') }
  let(:workout_offering) { FactoryBot.create(:workout_offering, workout: workout_course, course_offering: course_offering) }

  let!(:score_gym_alice) do
    FactoryBot.create(:workout_score, user: student, workout: workout_gym, workout_offering: nil, score: 85.0)
  end

  let!(:score_course_alice) do
    FactoryBot.create(:workout_score, user: student, workout: workout_course, workout_offering: workout_offering, score: 92.0)
  end

  let!(:score_gym_bob) do
    FactoryBot.create(:workout_score, user: other_student, workout: workout_gym, workout_offering: nil, score: 70.0)
  end

  describe "Authorization" do
    it "redirects unauthenticated users to sign in" do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects non-admin regular users with an authorization error" do
      sign_in student
      get :index
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include('not authorized')
    end
  end

  describe "GET #index" do
    render_views

    before do
      sign_in admin
    end

    it "renders the index template with status 200 for admins" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Workout Activity Logs')
      scores = controller.instance_variable_get(:@workout_scores)
      expect(scores).to include(score_gym_alice, score_course_alice, score_gym_bob)
    end

    it "filters workout scores by student email" do
      get :index, params: { student: 'alice@example.edu' }
      scores = controller.instance_variable_get(:@workout_scores)
      expect(scores).to include(score_gym_alice, score_course_alice)
      expect(scores).not_to include(score_gym_bob)
    end

    it "filters workout scores by student name" do
      get :index, params: { student: 'Smith' }
      scores = controller.instance_variable_get(:@workout_scores)
      expect(scores).to include(score_gym_alice, score_course_alice)
      expect(scores).not_to include(score_gym_bob)
    end

    it "filters workout scores by workout title" do
      get :index, params: { workout: 'Midterm Exam' }
      scores = controller.instance_variable_get(:@workout_scores)
      expect(scores).to include(score_course_alice)
      expect(scores).not_to include(score_gym_alice, score_gym_bob)
    end

    it "filters by gym-only scope" do
      get :index, params: { scope: 'gym' }
      scores = controller.instance_variable_get(:@workout_scores)
      expect(scores).to include(score_gym_alice, score_gym_bob)
      expect(scores).not_to include(score_course_alice)
    end

    it "filters by course-only scope" do
      get :index, params: { scope: 'course' }
      scores = controller.instance_variable_get(:@workout_scores)
      expect(scores).to include(score_course_alice)
      expect(scores).not_to include(score_gym_alice, score_gym_bob)
    end
  end

  describe "GET #show" do
    render_views

    before do
      sign_in admin
      ActivityLog.create!(
        user: student,
        workout: workout_gym,
        workout_score: score_gym_alice,
        activity: 'practice_view',
        ip_address: '127.0.0.1'
      )
    end

    it "renders activity_log template for a gym workout score" do
      get :show, params: { id: score_gym_alice.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Activity Log for')
      expect(response.body).to include('Back to Activity Logs')
      expect(controller.instance_variable_get(:@student)).to eq(student)
      expect(controller.instance_variable_get(:@workout)).to eq(workout_gym)
      expect(controller.instance_variable_get(:@workout_offering)).to be_nil
      events = controller.instance_variable_get(:@events)
      expect(events).not_to be_empty
      expect(events.first[:activity]).to eq('practice_view')
    end

    it "renders activity_log template for a course workout score" do
      get :show, params: { id: score_course_alice.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Activity Log for')
      expect(controller.instance_variable_get(:@student)).to eq(student)
      expect(controller.instance_variable_get(:@workout)).to eq(workout_course)
      expect(controller.instance_variable_get(:@workout_offering)).to eq(workout_offering)
      expect(controller.instance_variable_get(:@course_offering)).to eq(course_offering)
    end
  end
end
