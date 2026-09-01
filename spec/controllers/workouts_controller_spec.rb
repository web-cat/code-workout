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

  describe "GET #new_or_existing" do
    let(:mock_org) { double("Organization", id: 1, slug: "vt") }
    let(:mock_course) { double("Course", id: 10, slug: "cs1114", organization: mock_org) }
    let(:mock_term) { double("Term", id: 20, slug: "fall2026", display_name: "Fall 2026") }
    let(:mock_workout) { double("Workout", id: 100, name: "Loops") }
    let(:mock_offering) { double("WorkoutOffering", id: 200, workout: mock_workout) }
    let(:mock_course_offering) { double("CourseOffering", id: 300, term: mock_term, workout_offerings: [mock_offering]) }

    before do
      allow(Course).to receive(:find_with_id_or_slug).and_return(mock_course)
      allow(Term).to receive(:find).and_return(mock_term)
      allow(Organization).to receive(:find).and_return(mock_org)
      allow(controller).to receive(:can?).with(:new, Workout).and_return(true)
      allow(controller).to receive(:can?).with(:edit, anything).and_return(true)
    end

    it "scopes default results to recent terms and eager loads workouts" do
      course_offerings_relation = double("CourseOfferingsRelation")
      allow(mock_course).to receive(:course_offerings).and_return(course_offerings_relation)

      recent_query = double("RecentQuery")
      allow(course_offerings_relation).to receive(:joins).with(:term).and_return(recent_query)
      allow(recent_query).to receive(:where).with('terms.ends_on >= ?', anything).and_return(recent_query)
      allow(recent_query).to receive(:order).with('terms.ends_on DESC').and_return(recent_query)
      allow(recent_query).to receive(:distinct).and_return(recent_query)
      allow(recent_query).to receive(:pluck).with('terms.id').and_return([20])

      scoped_query = double("ScopedQuery")
      allow(course_offerings_relation).to receive(:where).with(term_id: [20]).and_return(scoped_query)
      allow(scoped_query).to receive(:joins).with(:term).and_return(scoped_query)
      allow(scoped_query).to receive(:order).with('terms.ends_on DESC').and_return(scoped_query)
      allow(scoped_query).to receive(:includes).with(:term, workout_offerings: { workout: :exercise_workouts }).and_return([mock_course_offering])

      get :new_or_existing, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: '20'
      }

      expect(response.status).to eq(200)
      default_results = controller.instance_variable_get(:@default_results)
      expect(default_results).to be_a(Hash)
      expect(default_results[mock_term]).to eq([mock_workout])
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
    end
  end

  describe "#create_or_update_offerings" do
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 30) }
    let(:user) { FactoryBot.build_stubbed(:user) }
    let(:term) { FactoryBot.build_stubbed(:term, id: 20, slug: 'fall-2026') }
    let(:course) { FactoryBot.build_stubbed(:course, id: 10, slug: 'itsc2214') }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(user).to receive(:managed_course_offerings).and_return([])
      allow(Term).to receive(:find).with('fall-2026').and_return(term)
      allow(Course).to receive(:find_with_id_or_slug).and_return(course)
      allow(workout).to receive(:workout_policy).and_return(nil)
      allow(WorkoutPolicy).to receive(:create!).and_return(double("WorkoutPolicy", id: 1, update: true))
      allow(workout).to receive_message_chain(:workout_offerings, :update_all).and_return(true)
      allow(workout).to receive_message_chain(:workout_offerings, :joins, :where).and_return([])
      allow(workout).to receive(:add_workout_offerings).and_return([])
      allow(workout).to receive(:save!).and_return(true)
    end

    it "handles blank date_yaml without raising NoMethodError on nil legacy params" do
      controller.params = ActionController::Parameters.new({
        date_yaml: "",
        course_id: "itsc2214",
        organization_id: "uncc",
        term_id: "fall-2026"
      })

      expect {
        controller.send(:create_or_update_offerings, workout)
      }.not_to raise_error
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

  describe "GET #find_offering" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall2026') }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 10, name: 'Practice Workout') }
    let(:course_offering) do
      FactoryBot.build_stubbed(:course_offering, id: 101, course: course, term: term, label: 'Section 1')
    end
    let(:workout_offering) do
      FactoryBot.build_stubbed(:workout_offering, id: 201, workout: workout, course_offering: course_offering)
    end
    let(:user) { FactoryBot.build_stubbed(:user, id: 1) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(User).to receive(:find).with(user.id.to_s).and_return(user)
      allow(Term).to receive(:find).with('fall2026').and_return(term)
      allow(Course).to receive(:find_with_id_or_slug).with('cs1114', 'vt').and_return(course)
      allow(user).to receive(:is_enrolled?).with(course_offering).and_return(false)
      allow(CourseEnrollment).to receive(:create).and_return(true)
      allow(workout_offering).to receive(:changed?).and_return(false)
      allow(course_offering).to receive(:changed?).and_return(false)
    end

    it "directly resolves to practice when WorkoutOffering exists with matching ext_lti_assignment_id" do
      allow(WorkoutOffering).to receive(:find_by).with(
        lms_instance_id: '1',
        lti_assignment_id: 'ext_assignment_100'
      ).and_return(workout_offering)

      get :find_offering, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        workout_name: 'Practice Workout',
        user_id: user.id.to_s,
        lms_instance_id: '1',
        ext_lti_assignment_id: 'ext_assignment_100'
      }

      expect(response).to redirect_to(
        organization_workout_offering_practice_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: 201,
          lti_launch: true
        )
      )
    end

    it "resolves when WorkoutOffering exists with legacy compound assignment id" do
      allow(WorkoutOffering).to receive(:find_by).with(
        lms_instance_id: '1',
        lti_assignment_id: 'legacy_100'
      ).and_return(nil)
      allow(WorkoutOffering).to receive(:find_by).with(
        lms_instance_id: '1',
        lms_assignment_id: 'legacy_100'
      ).and_return(nil)
      allow(WorkoutOffering).to receive(:find_by).with(
        lms_assignment_id: '1-legacy_100'
      ).and_return(workout_offering)

      get :find_offering, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        workout_name: 'Practice Workout',
        user_id: user.id.to_s,
        lms_instance_id: '1',
        ext_lti_assignment_id: 'legacy_100'
      }

      expect(response).to redirect_to(
        organization_workout_offering_practice_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: 201,
          lti_launch: true
        )
      )
    end

    it "renders lti/error for student when no workout offering and no candidate course offerings exist" do
      allow(WorkoutOffering).to receive(:find_by).and_return(nil)
      allow(user).to receive(:course_offerings_for_term).and_return([])

      get :find_offering, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        workout_name: 'Nonexistent Workout',
        user_id: user.id.to_s,
        lms_instance_id: '1',
        ext_lti_assignment_id: 'unmatched_id'
      }, session: { is_instructor: false }

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@message)).to include("not yet available")
    end
  end

  describe "#serialize_workout_offerings_to_yaml" do
    let(:user) { FactoryBot.build_stubbed(:user, first_name: 'John', last_name: 'Doe', email: 'jdoe@vt.edu') }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall-2026', season: 400, year: 2026) }
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cs1114') }
    let(:course_offering) { FactoryBot.build_stubbed(:course_offering, course: course, term: term, label: 'Section 1') }
    let(:workout_offering) do
      FactoryBot.build_stubbed(:workout_offering,
        course_offering: course_offering,
        soft_deadline: Time.zone.parse('2026-09-15 23:59:00'),
        opening_date: Time.zone.parse('2026-09-01 00:00:00'),
        hard_deadline: Time.zone.parse('2026-09-17 23:59:00')
      )
    end

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it "serializes StudentExtension model objects into extensions YAML" do
      extension = FactoryBot.build_stubbed(:student_extension,
        user: user,
        workout_offering: workout_offering,
        soft_deadline: Time.zone.parse('2026-09-20 23:59:00'),
        opening_date: Time.zone.parse('2026-09-01 00:00:00'),
        hard_deadline: Time.zone.parse('2026-09-22 23:59:00')
      )

      yaml = controller.send(:serialize_workout_offerings_to_yaml, [workout_offering], [extension])
      data = YAML.safe_load(yaml)

      expect(data['sections']).to be_an(Array)
      expect(data['sections'].first['section']).to eq(course_offering.display_name_with_term)
      expect(data['extensions']).to be_an(Array)
      expect(data['extensions'].first['students']).to include("John Doe <jdoe@vt.edu>")
    end

    it "serializes extension Hashes without raising NoMethodError" do
      ext_hash = {
        student_id: user.id,
        student_display: 'John Doe',
        student_email: 'jdoe@vt.edu',
        soft_deadline: Time.zone.parse('2026-09-20 23:59:00').to_i,
        opening_date: Time.zone.parse('2026-09-01 00:00:00').to_i,
        hard_deadline: Time.zone.parse('2026-09-22 23:59:00').to_i
      }

      yaml = controller.send(:serialize_workout_offerings_to_yaml, [workout_offering], [ext_hash])
      data = YAML.safe_load(yaml)

      expect(data['extensions'].first['students']).to include("John Doe <jdoe@vt.edu>")
    end
  end
end
