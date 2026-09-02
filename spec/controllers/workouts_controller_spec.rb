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
    let(:mock_org) { double("Organization", id: 1, slug: "vt", to_param: "vt") }
    let(:mock_course) { double("Course", id: 10, slug: "cs1114", to_param: "cs1114", organization: mock_org) }
    let(:mock_term) { double("Term", id: 20, slug: "fall2026", to_param: "fall2026", display_name: "Fall 2026") }
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
      allow(scoped_query).to receive(:includes).with(:term, workout_offerings: { workout: [:tags, :exercise_workouts] }).and_return([mock_course_offering])

      get :new_or_existing, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: '20'
      }

      expect(response.status).to eq(200)
      default_results = controller.instance_variable_get(:@default_results)
      expect(default_results).to be_a(Hash)
      expect(default_results[mock_term]).to eq([mock_workout])
      new_workout_path = controller.instance_variable_get(:@new_workout_path)
      expect(new_workout_path).to eq("/courses/vt/cs1114/fall2026/workouts/new")
    end
  end

  describe "GET #new" do
    let(:user) { FactoryBot.build_stubbed(:user) }
    let(:mock_org) { double("Organization", id: 1, slug: "vt", to_param: "vt") }
    let(:mock_course) { double("Course", id: 10, slug: "cs1114", to_param: "cs1114", organization: mock_org) }
    let(:mock_term) { double("Term", id: 20, slug: "fall2026", to_param: "fall2026", display_name: "Fall 2026") }
    let(:mock_course_offering) do
      double("CourseOffering", id: 300, display_name_with_term: "CS 1114 (Fall 2026, 98765)", term: mock_term)
    end

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(user).to receive_message_chain(:global_role, :is_admin?).and_return(true)
      allow(Course).to receive(:find_with_id_or_slug).and_return(mock_course)
      allow(Term).to receive(:find).and_return(mock_term)
      allow(Organization).to receive(:find).and_return(mock_org)
      allow(user).to receive(:managed_course_offerings).and_return([mock_course_offering])
    end

    it "prepopulates @date_yaml with managed course offerings" do
      get :new, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026'
      }

      expect(response.status).to eq(200)
      date_yaml = controller.instance_variable_get(:@date_yaml)
      expect(date_yaml).to include("CS 1114 (Fall 2026, 98765)")
      expect(date_yaml).to include("sections:")
    end
  end

  describe "GET #clone" do
    let(:user) { FactoryBot.build_stubbed(:user) }
    let(:mock_org) { double("Organization", id: 1, slug: "vt", to_param: "vt") }
    let(:mock_course) { double("Course", id: 10, slug: "cs1114", to_param: "cs1114", organization: mock_org) }
    let(:mock_term) { double("Term", id: 20, slug: "fall2026", to_param: "fall2026", display_name: "Fall 2026") }
    let(:mock_workout) { double("Workout", id: 100, name: "Loops", workout_policy: nil, exercise_workouts: [], workout_offerings: []) }
    let(:mock_course_offering) do
      double("CourseOffering", id: 300, display_name_with_term: "CS 1114 (Fall 2026, 98765)", term: mock_term)
    end

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:authorize!).and_return(true)
      allow(Workout).to receive(:find).and_return(mock_workout)
      allow(Course).to receive(:find_with_id_or_slug).and_return(mock_course)
      allow(Term).to receive(:find).and_return(mock_term)
      allow(Organization).to receive(:find).and_return(mock_org)
      allow(user).to receive(:managed_course_offerings).and_return([mock_course_offering])
    end

    it "prepopulates @date_yaml with managed course offerings" do
      get :clone, params: {
        id: '100',
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026'
      }

      expect(response.status).to eq(200)
      date_yaml = controller.instance_variable_get(:@date_yaml)
      expect(date_yaml).to include("CS 1114 (Fall 2026, 98765)")
      expect(date_yaml).to include("sections:")
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
      allow(ActivityLog).to receive(:create).and_return(true)
    end

    it "logs a workout_view in ActivityLog when user is logged in" do
      user = FactoryBot.build_stubbed(:user)
      allow(controller).to receive(:current_user).and_return(user)
      expect(ActivityLog).to receive(:create).with(
        hash_including(
          user: user,
          activity: 'workout_view',
          lti_launch: false
        )
      )

      get :show, params: { id: 1 }
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

    context "when workout_offering is present and IP restrictions apply" do
      let(:mock_offering) { double("WorkoutOffering", id: 201) }
      let(:mock_score) { double("WorkoutScore", id: 99) }
      let(:user) { FactoryBot.build_stubbed(:user) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        controller.instance_variable_set(:@workout_offering, mock_offering)
        allow(mock_workout).to receive(:score_for).and_return(mock_score)
      end

      it "blocks access and logs workout_view_ip_blocked when IP is disallowed" do
        allow(mock_offering).to receive(:ip_allowed?).with('10.0.0.1', user, mock_score).and_return(false)

        expect(ActivityLog).to receive(:create).with(hash_including(
          user: user,
          workout_offering: mock_offering,
          activity: 'workout_view_ip_blocked',
          ip_address: '10.0.0.1'
        ))

        request.env['REMOTE_ADDR'] = '10.0.0.1'
        get :show, params: { id: 1 }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@message)).to include("10.0.0.1")
      end

      it "blocks access and logs workout_view_user_agent_blocked when browser user agent is disallowed" do
        allow(mock_offering).to receive(:ip_allowed?).and_return(true)
        allow(mock_offering).to receive(:user_agent_allowed?).with('DisallowedBrowser/1.0', user, mock_score).and_return(false)

        expect(ActivityLog).to receive(:create).with(hash_including(
          user: user,
          workout_offering: mock_offering,
          activity: 'workout_view_user_agent_blocked',
          user_agent: 'DisallowedBrowser/1.0'
        ))

        request.env['HTTP_USER_AGENT'] = 'DisallowedBrowser/1.0'
        get :show, params: { id: 1 }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@message)).to include("requires a specific browser")
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

    it "parses top-level ips and per-section ips overrides" do
      co1 = FactoryBot.build_stubbed(:course_offering, id: 101, label: 'Section A', course: course, term: term)
      co2 = FactoryBot.build_stubbed(:course_offering, id: 102, label: 'Section B', course: course, term: term)
      allow(co1).to receive(:display_name_with_term).and_return('Section A')
      allow(co1).to receive(:display_name_with_org_and_term).and_return('Section A')
      allow(co1).to receive(:display_name).and_return('Section A')
      allow(co2).to receive(:display_name_with_term).and_return('Section B')
      allow(co2).to receive(:display_name_with_org_and_term).and_return('Section B')
      allow(co2).to receive(:display_name).and_return('Section B')
      allow(user).to receive(:managed_course_offerings).and_return([co1, co2])

      yaml_input = <<~YAML
        ips: 128.173.*.*
        sections:
          - section: Section A
            due: 2026-09-15 11:59 PM
          - section: Section B
            due: 2026-09-15 11:59 PM
            ips: 192.168.1.0/24
      YAML

      controller.params = ActionController::Parameters.new({
        date_yaml: yaml_input,
        course_id: "itsc2214",
        organization_id: "uncc",
        term_id: "fall-2026"
      })

      expect(workout).to receive(:add_workout_offerings) do |offerings_data, common|
        expect(offerings_data['101']['allowed_ips']).to eq('128.173.*.*')
        expect(offerings_data['102']['allowed_ips']).to eq('192.168.1.0/24')
        []
      end

      controller.send(:create_or_update_offerings, workout)
    end

    it "parses student extension ips overrides" do
      co1 = FactoryBot.build_stubbed(:course_offering, id: 101, label: 'Section A', course: course, term: term)
      wo1 = FactoryBot.build_stubbed(:workout_offering, id: 201, course_offering: co1, workout: workout)
      allow(co1).to receive(:display_name_with_term).and_return('Section A')
      allow(co1).to receive(:display_name_with_org_and_term).and_return('Section A')
      allow(co1).to receive(:display_name).and_return('Section A')
      allow(user).to receive(:managed_course_offerings).and_return([co1])
      allow(workout).to receive(:add_workout_offerings).and_return([wo1])
      allow(workout).to receive_message_chain(:workout_offerings, :joins, :where).and_return([wo1])

      student = FactoryBot.build_stubbed(:user, email: 'student@example.edu')
      allow(User).to receive(:find_by).with(email: 'student@example.edu').and_return(student)
      allow(co1).to receive(:is_enrolled?).with(student).and_return(true)

      yaml_input = <<~YAML
        sections:
          - section: Section A
            due: 2026-09-15 11:59 PM
            ips: 192.168.1.0/24
        extensions:
          - due: 2026-09-20 11:59 PM
            ips: any
            students:
              - student@example.edu
      YAML

      controller.params = ActionController::Parameters.new({
        date_yaml: yaml_input,
        course_id: "itsc2214",
        organization_id: "uncc",
        term_id: "fall-2026"
      })

      expect(StudentExtension).to receive(:create!).with(hash_including(
        user: student,
        workout_offering: wo1,
        allowed_ips: 'any'
      ))

      controller.send(:create_or_update_offerings, workout)
    end
    it "parses top-level and per-section browsers requirements from YAML" do
      co1 = FactoryBot.build_stubbed(:course_offering, id: 101, label: 'Section A', course: course, term: term)
      co2 = FactoryBot.build_stubbed(:course_offering, id: 102, label: 'Section B', course: course, term: term)
      allow(co1).to receive(:display_name_with_term).and_return('Section A')
      allow(co1).to receive(:display_name_with_org_and_term).and_return('Section A')
      allow(co1).to receive(:display_name).and_return('Section A')
      allow(co2).to receive(:display_name_with_term).and_return('Section B')
      allow(co2).to receive(:display_name_with_org_and_term).and_return('Section B')
      allow(co2).to receive(:display_name).and_return('Section B')
      allow(user).to receive(:managed_course_offerings).and_return([co1, co2])

      yaml_input = <<~YAML
        browsers: LockDown Browser
        sections:
          - section: Section A
            due: 2026-09-15 11:59 PM
          - section: Section B
            due: 2026-09-15 11:59 PM
            browsers: SEB
      YAML

      controller.params = ActionController::Parameters.new({
        date_yaml: yaml_input,
        course_id: "itsc2214",
        organization_id: "uncc",
        term_id: "fall-2026"
      })

      expect(workout).to receive(:add_workout_offerings) do |offerings_data, common|
        expect(offerings_data['101']['allowed_user_agents']).to eq('LockDown Browser')
        expect(offerings_data['102']['allowed_user_agents']).to eq('SEB')
        []
      end

      controller.send(:create_or_update_offerings, workout)
    end

    it "parses student extension browsers overrides" do
      co1 = FactoryBot.build_stubbed(:course_offering, id: 101, label: 'Section A', course: course, term: term)
      wo1 = FactoryBot.build_stubbed(:workout_offering, id: 201, course_offering: co1, workout: workout)
      allow(co1).to receive(:display_name_with_term).and_return('Section A')
      allow(co1).to receive(:display_name_with_org_and_term).and_return('Section A')
      allow(co1).to receive(:display_name).and_return('Section A')
      allow(user).to receive(:managed_course_offerings).and_return([co1])
      allow(workout).to receive(:add_workout_offerings).and_return([wo1])
      allow(workout).to receive_message_chain(:workout_offerings, :joins, :where).and_return([wo1])

      student = FactoryBot.build_stubbed(:user, email: 'student@example.edu')
      allow(User).to receive(:find_by).with(email: 'student@example.edu').and_return(student)
      allow(co1).to receive(:is_enrolled?).with(student).and_return(true)

      yaml_input = <<~YAML
        sections:
          - section: Section A
            due: 2026-09-15 11:59 PM
            browsers: LockDown Browser
        extensions:
          - due: 2026-09-20 11:59 PM
            browsers: any
            students:
              - student@example.edu
      YAML

      controller.params = ActionController::Parameters.new({
        date_yaml: yaml_input,
        course_id: "itsc2214",
        organization_id: "uncc",
        term_id: "fall-2026"
      })

      expect(StudentExtension).to receive(:create!).with(hash_including(
        user: student,
        workout_offering: wo1,
        allowed_user_agents: 'any'
      ))

      controller.send(:create_or_update_offerings, workout)
    end
  end

  describe "#serialize_workout_offerings_to_yaml" do
    let(:user) { FactoryBot.build_stubbed(:user) }
    let(:course_offering1) { FactoryBot.build_stubbed(:course_offering, id: 101, label: 'Section 1') }
    let(:course_offering2) { FactoryBot.build_stubbed(:course_offering, id: 102, label: 'Section 2') }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(user).to receive_message_chain(:time_zone, :name).and_return('America/New_York')
      allow(course_offering1).to receive(:display_name_with_term).and_return('CS 101 (Fall 2026, 11111)')
      allow(course_offering2).to receive(:display_name_with_term).and_return('CS 101 (Fall 2026, 22222)')
    end

    it "serializes common ips at top level when all sections share same allowed_ips" do
      wo1 = FactoryBot.build_stubbed(:workout_offering, course_offering: course_offering1, allowed_ips: '128.173.*.*')
      wo2 = FactoryBot.build_stubbed(:workout_offering, course_offering: course_offering2, allowed_ips: '128.173.*.*')

      yaml_str = controller.send(:serialize_workout_offerings_to_yaml, [wo1, wo2], [])
      expect(yaml_str).to match(/^ips:\s*128\.173\.\*\.\*/)
      expect(yaml_str).not_to match(/section:.*\n\s*ips:/)
    end

    it "serializes common browsers at top level when all sections share same allowed_user_agents" do
      wo1 = FactoryBot.build_stubbed(:workout_offering, course_offering: course_offering1, allowed_user_agents: 'LockDown Browser')
      wo2 = FactoryBot.build_stubbed(:workout_offering, course_offering: course_offering2, allowed_user_agents: 'LockDown Browser')

      yaml_str = controller.send(:serialize_workout_offerings_to_yaml, [wo1, wo2], [])
      expect(yaml_str).to match(/^browsers:\s*LockDown Browser/)
      expect(yaml_str).not_to match(/section:.*\n\s*browsers:/)
    end

    it "serializes per-section ips when sections have different allowed_ips" do
      wo1 = FactoryBot.build_stubbed(:workout_offering, course_offering: course_offering1, allowed_ips: '128.173.*.*')
      wo2 = FactoryBot.build_stubbed(:workout_offering, course_offering: course_offering2, allowed_ips: '192.168.1.0/24')

      yaml_str = controller.send(:serialize_workout_offerings_to_yaml, [wo1, wo2], [])
      expect(yaml_str).not_to match(/^ips:/)
      expect(yaml_str).to include("ips: 128.173.*.*")
      expect(yaml_str).to include("ips: 192.168.1.0/24")
    end

    it "serializes per-section browsers when sections have different allowed_user_agents" do
      wo1 = FactoryBot.build_stubbed(:workout_offering, course_offering: course_offering1, allowed_user_agents: 'LockDown Browser')
      wo2 = FactoryBot.build_stubbed(:workout_offering, course_offering: course_offering2, allowed_user_agents: 'SEB')

      yaml_str = controller.send(:serialize_workout_offerings_to_yaml, [wo1, wo2], [])
      expect(yaml_str).not_to match(/^browsers:/)
      expect(yaml_str).to include("browsers: LockDown Browser")
      expect(yaml_str).to include("browsers: SEB")
    end

    it "serializes ips on student extensions" do
      wo1 = FactoryBot.build_stubbed(:workout_offering, course_offering: course_offering1)
      ext_student = FactoryBot.build_stubbed(:user, first_name: 'Jane', last_name: 'Doe', email: 'jdoe@example.edu')
      ext = FactoryBot.build_stubbed(
        :student_extension,
        user: ext_student,
        workout_offering: wo1,
        allowed_ips: 'any'
      )

      yaml_str = controller.send(:serialize_workout_offerings_to_yaml, [wo1], [ext])
      expect(yaml_str).to include("ips: any")
      expect(yaml_str).to include("Jane Doe <jdoe@example.edu>")
    end

    it "serializes browsers on student extensions" do
      wo1 = FactoryBot.build_stubbed(:workout_offering, course_offering: course_offering1)
      ext_student = FactoryBot.build_stubbed(:user, first_name: 'Jane', last_name: 'Doe', email: 'jdoe@example.edu')
      ext = FactoryBot.build_stubbed(
        :student_extension,
        user: ext_student,
        workout_offering: wo1,
        allowed_user_agents: 'any'
      )

      yaml_str = controller.send(:serialize_workout_offerings_to_yaml, [wo1], [ext])
      expect(yaml_str).to include("browsers: any")
      expect(yaml_str).to include("Jane Doe <jdoe@example.edu>")
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

    it "redirects instructor to new course offering creation when no course offerings exist" do
      allow(WorkoutOffering).to receive(:find_by).and_return(nil)
      allow(user).to receive(:managed_course_offerings).and_return([])

      get :find_offering, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        workout_name: 'Example CBTF Question',
        user_id: user.id.to_s,
        lms_instance_id: '1',
        ext_lti_assignment_id: '53db16ed-ee26-4b6b-82e7-0e2cee966c05',
        custom_canvas_assignment_id: '2853105',
        resource_link_id: 'f8b49093fc74aa27938a038e21565149b24b697c'
      }, session: { is_instructor: true }

      expect(response).to redirect_to(
        organization_new_course_offering_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          workout_name: 'Example CBTF Question',
          ext_lti_assignment_id: '53db16ed-ee26-4b6b-82e7-0e2cee966c05',
          custom_canvas_assignment_id: '2853105',
          resource_link_id: 'f8b49093fc74aa27938a038e21565149b24b697c',
          from_collection: nil
        )
      )
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
