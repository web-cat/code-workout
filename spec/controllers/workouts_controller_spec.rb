require 'spec_helper'

describe WorkoutsController do
  describe "GET #index" do
    it "responds successfully and assigns @workouts" do
      get :index
      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@workouts)).not_to be_nil
    end

    context "when a user is logged in" do
      it "preloads workout scores grouped by workout ID" do
        user = FactoryBot.build_stubbed(:user)
        allow(controller).to receive(:current_user).and_return(user)

        get :index
        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@workout_scores_by_workout_id)).to be_a(Hash)
      end
    end
  end

  describe "GET #gym" do
    it "responds successfully and assigns @gym" do
      get :gym
      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@gym)).not_to be_nil
    end

    context "when a user is logged in" do
      it "preloads workout scores grouped by workout ID" do
        user = FactoryBot.build_stubbed(:user)
        allow(controller).to receive(:current_user).and_return(user)

        get :gym
        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@workout_scores_by_workout_id)).to be_a(Hash)
      end
    end
  end

  describe "GET #show" do
    let(:mock_workout) do
      double(
        "Workout",
        id: 1,
        name: "Test Workout",
        is_public: true,
        creator: nil,
        tags: [],
        owners: [],
        exercise_workouts: [],
        workout_offerings: [],
        exercises: double("ExercisesRelation", includes: [])
      )
    end

    before do
      allow(Workout).to receive_message_chain(:includes, :find).and_return(mock_workout)
      allow(mock_workout).to receive(:score_for).and_return(nil)
      allow(controller).to receive(:cannot?).with(:read, mock_workout).and_return(false)
    end

    it "responds successfully and assigns @workout and @exs" do
      get :show, params: { id: 1 }
      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@workout)).to eq(mock_workout)
      expect(controller.instance_variable_get(:@exs)).not_to be_nil
    end

    context "when a user is logged in without workout score" do
      it "preloads standalone user attempts" do
        user = FactoryBot.build_stubbed(:user)
        allow(controller).to receive(:current_user).and_return(user)

        get :show, params: { id: 1 }
        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@attempts_by_version_id)).to be_a(Hash)
      end
    end

    context "when a user is logged in with an active workout score" do
      let(:mock_score) { double("WorkoutScore", id: 99) }

      before do
        allow(mock_workout).to receive(:score_for).and_return(mock_score)
      end

      it "preloads scoring attempts for the workout score" do
        user = FactoryBot.build_stubbed(:user)
        allow(controller).to receive(:current_user).and_return(user)

        get :show, params: { id: 1 }
        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@scoring_attempts_by_version_id)).to be_a(Hash)
      end
    end
  end

  describe "GET #course_workout_show and #course_workout_practice" do
    let(:organization) { double("Organization", id: 1, slug: 'vt') }
    let(:course) { double("Course", id: 10, slug: 'cs1114', organization: organization) }
    let(:term) { double("Term", id: 20, slug: 'fall2026') }
    let(:workout) { double("Workout", id: 30, name: "Recursion Practice") }
    let(:course_offering) do
      double("CourseOffering", id: 100, course: course, term: term, is_enrolled?: true, is_staff?: false)
    end
    let(:workout_offering) do
      double("WorkoutOffering", id: 200, workout: workout, course_offering: course_offering)
    end

    before do
      allow(Organization).to receive(:find).with('vt').and_return(organization)
      allow(Course).to receive(:find_with_id_or_slug).with('cs1114', organization).and_return(course)
      allow(Term).to receive(:find).with('fall2026').and_return(term)
    end

    it "redirects to the user's enrolled section workout offering show page using numeric ID" do
      allow(Workout).to receive(:find_by_id_or_name).with('30', course, term).and_return(workout)
      allow(workout).to receive(:workout_offering_for).and_return(workout_offering)

      get :course_workout_show, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        id: '30'
      }

      expect(response).to redirect_to(
        organization_workout_offering_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: 200
        )
      )
    end

    it "redirects to the user's enrolled section workout offering practice page using parameterized slug" do
      allow(Workout).to receive(:find_by_id_or_name).with('recursion-practice', course, term).and_return(workout)
      allow(workout).to receive(:workout_offering_for).and_return(workout_offering)

      get :course_workout_practice, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        id: 'recursion-practice'
      }

      expect(response).to redirect_to(
        organization_workout_offering_practice_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: 200
        )
      )
    end
  end

  describe "PATCH #update" do
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 30) }
    let(:user) { FactoryBot.build_stubbed(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:cannot?).and_return(false)
      allow(Workout).to receive_message_chain(:includes, :find).and_return(workout)
      allow(workout).to receive(:update_or_create).and_return(workout)
      allow(controller).to receive(:create_or_update_offerings).and_return(true)
    end

    it "returns the organization_course_workout_path JSON url when course_id is present" do
      patch :update, params: {
        id: '30',
        course_id: 'cs1114',
        organization_id: 'vt',
        term_id: 'fall2026'
      }, format: :json

      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['url']).to eq('/courses/vt/cs1114/fall2026/workouts/30')
    end

    it "returns 422 with error message when workout errors are present" do
      allow(controller).to receive(:create_or_update_offerings) do |w|
        w.errors.add(:base, "Invalid section date")
      end

      patch :update, params: {
        id: '30',
        course_id: 'cs1114',
        organization_id: 'vt',
        term_id: 'fall2026'
      }, format: :json

      expect(response.status).to eq(422)
      json = JSON.parse(response.body)
      expect(json['error']).to include("Invalid section date")
    end
  end

  describe "#parse_date" do
    let(:tz) { 'America/New_York' }

    it "correctly parses absolute date strings with time" do
      result = controller.send(:parse_date, '2026-09-15 11:59 PM', tz)
      expect(result.year).to eq(2026)
      expect(result.month).to eq(9)
      expect(result.day).to eq(15)
      expect(result.hour).to eq(23)
      expect(result.min).to eq(59)
    end

    it "correctly parses relative offsets for hard deadlines" do
      base_time = Time.zone.parse('2026-09-15 12:00:00')
      result = controller.send(:parse_date, '+2 days', tz, base_time, :until)
      expect(result).to eq(base_time + 2.days)
    end

    it "correctly handles Time and Date objects directly" do
      time_obj = Time.zone.parse('2026-09-15 10:00:00')
      result = controller.send(:parse_date, time_obj, tz)
      expect(result).to eq(time_obj.in_time_zone(tz))
    end
  end
end
