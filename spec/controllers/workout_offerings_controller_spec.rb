require 'spec_helper'

RSpec.describe WorkoutOfferingsController, type: :controller do
  describe "Fallback section resolution (resolve_section_offering)" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall2026') }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 10, name: 'Practice Workout') }

    let(:section1) do
      FactoryBot.build_stubbed(:course_offering, id: 101, course: course, term: term, label: 'Section 1')
    end
    let(:section2) do
      FactoryBot.build_stubbed(:course_offering, id: 102, course: course, term: term, label: 'Section 2')
    end

    let(:offering_section1) do
      FactoryBot.build_stubbed(:workout_offering, id: 201, workout: workout, course_offering: section1)
    end
    let(:offering_section2) do
      FactoryBot.build_stubbed(:workout_offering, id: 202, workout: workout, course_offering: section2)
    end

    let(:student) { FactoryBot.build_stubbed(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(student)
      allow(WorkoutOffering).to receive_message_chain(:includes, :find_by).and_return(offering_section1)
      allow(section1).to receive(:is_staff?).with(student).and_return(false)
      allow(section1).to receive(:is_enrolled?).with(student).and_return(false)
      allow(student).to receive(:course_offerings_for_term).with(term, course).and_return([section2])
      allow(WorkoutOffering).to receive(:where).with(
        course_offering_id: [102],
        workout_id: workout.id
      ).and_return([offering_section2])
    end

    it "redirects a student enrolled in Section 2 from Section 1's show URL to Section 2's offering" do
      get :show, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        id: '201'
      }

      expect(response).to redirect_to(
        organization_workout_offering_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: 202
        )
      )
    end

    it "redirects a student enrolled in Section 2 from Section 1's practice URL to Section 2's offering practice" do
      get :practice, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        id: '201',
        exercise_id: '5'
      }

      expect(response).to redirect_to(
        organization_workout_offering_practice_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: 202,
          exercise_id: '5'
        )
      )
    end
  end

  describe "GET #show" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall2026') }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 10, name: 'Practice Workout', exercises: []) }
    let(:section1) do
      FactoryBot.build_stubbed(:course_offering, id: 101, course: course, term: term, label: 'Section 1')
    end
    let(:workout_offering) do
      FactoryBot.build_stubbed(:workout_offering, id: 201, workout: workout, course_offering: section1)
    end
    let(:user) { FactoryBot.build_stubbed(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(WorkoutOffering).to receive_message_chain(:includes, :find_by).and_return(workout_offering)
      allow(section1).to receive(:is_staff?).with(user).and_return(true)
      allow(workout_offering).to receive(:score_for).and_return(nil)
      allow(ActivityLog).to receive(:create).and_return(true)
    end

    it "renders the show view with preloaded workout, course, and attempt structures" do
      get :show, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        id: '201'
      }

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@workout)).to eq(workout)
      expect(controller.instance_variable_get(:@course_offering)).to eq(section1)
      expect(controller.instance_variable_get(:@attempts_by_version_id)).to be_a(Hash)
    end

    context "when a workout score exists" do
      let(:workout_score) { double("WorkoutScore", scored_attempts: []) }

      before do
        allow(workout_offering).to receive(:score_for).with(user).and_return(workout_score)
      end

      it "preloads scored_attempts grouped by exercise_version_id" do
        get :show, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@scoring_attempts_by_version_id)).to be_a(Hash)
      end
    end

    it "logs a workout_view in ActivityLog" do
      expect(ActivityLog).to receive(:create).with(
        hash_including(
          user: user,
          workout: workout,
          workout_offering: workout_offering,
          activity: 'workout_view',
          lti_launch: false
        )
      )

      get :show, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        id: '201'
      }
    end
  end

  describe "GET #practice with LTI launch" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall2026') }
    let(:exercise) { FactoryBot.build_stubbed(:exercise, id: 1) }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 10, name: 'Practice Workout') }
    let(:section1) do
      FactoryBot.build_stubbed(:course_offering, id: 101, course: course, term: term, label: 'Section 1')
    end
    let(:workout_offering) do
      FactoryBot.build_stubbed(:workout_offering, id: 201, workout: workout, course_offering: section1)
    end
    let(:user) { FactoryBot.build_stubbed(:user) }
    let(:workout_score) { FactoryBot.build_stubbed(:workout_score, id: 301, user: user, workout_offering: workout_offering, workout: workout) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(WorkoutOffering).to receive(:find).with('201').and_return(workout_offering)
      allow(WorkoutOffering).to receive(:find_by).with(id: '201').and_return(workout_offering)
      allow(user).to receive(:can?).with(:practice, workout_offering).and_return(true)
      allow(workout_offering).to receive(:score_for).with(user).and_return(workout_score)
      allow(workout_offering).to receive(:can_be_practiced_by?).with(user).and_return(true)
      allow(workout).to receive(:first_exercise).and_return(exercise)
      allow(workout_score).to receive(:closed?).and_return(false)
      allow(controller).to receive(:lti_enroll).and_return(true)
      allow(section1).to receive(:is_staff?).with(user).and_return(false)
    end

    it "logs a successful lti_launch in ActivityLog" do
      expect(ActivityLog).to receive(:create).with(
        hash_including(
          user: user,
          workout: workout,
          workout_offering: workout_offering,
          workout_score: workout_score,
          activity: 'lti_launch',
          lti_launch: true
        )
      )

      get :practice, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        id: '201',
        lti_launch: 'true'
      }
    end
  end

  describe "GET #activity_log" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall2026') }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 10, name: 'Practice Workout') }
    let(:section1) do
      FactoryBot.build_stubbed(:course_offering, id: 101, course: course, term: term, label: 'Section 1')
    end
    let(:workout_offering) do
      FactoryBot.build_stubbed(:workout_offering, id: 201, workout: workout, course_offering: section1)
    end
    let(:instructor) { FactoryBot.build_stubbed(:user) }
    let(:student) { FactoryBot.build_stubbed(:user) }
    let(:workout_score) { FactoryBot.build_stubbed(:workout_score, id: 301, user: student, workout_offering: workout_offering, workout: workout) }

    let(:log1) do
      double("ActivityLog",
        created_at: 2.hours.ago,
        activity: 'workout_view',
        ip_address: '1.2.3.4',
        user_agent: 'Mozilla/5.0',
        lti_launch: false
      )
    end
    let(:log2) do
      double("ActivityLog",
        created_at: 1.hour.ago,
        activity: 'lti_launch',
        ip_address: '1.2.3.4',
        user_agent: 'Mozilla/5.0',
        lti_launch: true
      )
    end

    before do
      allow(controller).to receive(:current_user).and_return(instructor)
      allow(instructor).to receive_message_chain(:global_role, :is_admin?).and_return(false)
      allow(WorkoutOffering).to receive(:find).with('201').and_return(workout_offering)
      allow(WorkoutScore).to receive(:find).with('301').and_return(workout_score)
      allow(section1).to receive(:is_staff?).with(instructor).and_return(true)

      activity_scope1 = double("ActivityScope1")
      activity_scope2 = double("ActivityScope2")
      allow(ActivityLog).to receive(:where).with(workout_score: workout_score).and_return(activity_scope1)
      allow(ActivityLog).to receive(:where).with(workout_offering: workout_offering, user: student).and_return(activity_scope2)
      allow(activity_scope1).to receive(:or).with(activity_scope2).and_return([log1, log2])

      allow(Attempt).to receive(:where).with(workout_score: workout_score).and_return([])
      allow(VisualizationLogging).to receive(:where).with(workout_score: workout_score).and_return([])
    end

    it "gathers activity log events including workout_view and lti_launch" do
      get :activity_log, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        id: '201',
        workout_score_id: '301'
      }

      expect(response.status).to eq(200)
      events = controller.instance_variable_get(:@events)
      expect(events.length).to eq(2)
      expect(events.map { |e| e[:activity] }).to contain_exactly('workout_view', 'lti_launch')
    end
  end

  describe "IP access restrictions enforcement" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall2026') }
    let(:course_offering) { FactoryBot.build_stubbed(:course_offering, id: 101, course: course, term: term, label: 'Section 1') }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 10, name: 'Sample Workout') }
    let(:workout_offering) do
      FactoryBot.build_stubbed(
        :workout_offering,
        id: 201,
        workout: workout,
        course_offering: course_offering,
        allowed_ips: '192.168.1.0/24'
      )
    end
    let(:student) { FactoryBot.build_stubbed(:user, id: 50) }

    before do
      allow(controller).to receive(:current_user).and_return(student)
      allow(WorkoutOffering).to receive_message_chain(:includes, :find_by).and_return(workout_offering)
      allow(WorkoutOffering).to receive(:find_by).with(id: '201').and_return(workout_offering)
      allow(course_offering).to receive(:is_staff?).with(student).and_return(false)
      allow(course_offering).to receive(:is_enrolled?).with(student).and_return(true)
      allow(workout_offering).to receive(:score_for).with(student).and_return(nil)
      allow(controller).to receive(:authorize!).and_return(true)
    end

    describe "GET #show" do
      it "blocks access and logs activity when client IP is not allowed" do
        allow(workout_offering).to receive(:ip_allowed?).with('10.0.0.1', student, nil).and_return(false)

        expect(ActivityLog).to receive(:create).with(hash_including(
          user: student,
          workout_offering: workout_offering,
          activity: 'workout_view_ip_blocked',
          ip_address: '10.0.0.1'
        ))

        request.env['REMOTE_ADDR'] = '10.0.0.1'
        get :show, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@message)).to include("10.0.0.1")
      end

      it "permits access and logs workout_view when client IP is allowed" do
        allow(workout_offering).to receive(:ip_allowed?).with('192.168.1.50', student, nil).and_return(true)

        expect(ActivityLog).to receive(:create).with(hash_including(
          user: student,
          workout_offering: workout_offering,
          activity: 'workout_view',
          ip_address: '192.168.1.50'
        ))

        request.env['REMOTE_ADDR'] = '192.168.1.50'
        get :show, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@message)).to be_nil
      end

      it "blocks workout view and logs activity when browser user agent is not allowed" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).with('DisallowedBrowser/1.0', student, nil).and_return(false)

        expect(ActivityLog).to receive(:create).with(hash_including(
          user: student,
          workout_offering: workout_offering,
          activity: 'workout_view_user_agent_blocked',
          user_agent: 'DisallowedBrowser/1.0'
        ))

        request.env['HTTP_USER_AGENT'] = 'DisallowedBrowser/1.0'
        get :show, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@message)).to include("requires a specific browser")
      end
    end

    describe "GET #practice" do
      it "blocks practice access and logs activity when client IP is not allowed" do
        allow(workout_offering).to receive(:ip_allowed?).with('10.0.0.1', student, nil).and_return(false)

        expect(ActivityLog).to receive(:create).with(hash_including(
          user: student,
          workout_offering: workout_offering,
          activity: 'practice_view_ip_blocked',
          ip_address: '10.0.0.1'
        ))

        request.env['REMOTE_ADDR'] = '10.0.0.1'
        get :practice, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@message)).to include("10.0.0.1")
      end

      it "blocks practice access and logs activity when browser user agent is not allowed" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).with('DisallowedBrowser/1.0', student, nil).and_return(false)

        expect(ActivityLog).to receive(:create).with(hash_including(
          user: student,
          workout_offering: workout_offering,
          activity: 'practice_view_user_agent_blocked',
          user_agent: 'DisallowedBrowser/1.0'
        ))

        request.env['HTTP_USER_AGENT'] = 'DisallowedBrowser/1.0'
        get :practice, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@message)).to include("requires a specific browser")
      end
    end

    describe "GET #error" do
      it "renders the error template with message" do
        get :error, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201',
          message: 'Custom network location error'
        }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@message)).to eq('Custom network location error')
      end
    end
  end
end
