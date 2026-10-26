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

    it "logs a successful lti_launch in ActivityLog including user_agent" do
      expect(ActivityLog).to receive(:create).with(
        hash_including(
          user: user,
          workout: workout,
          workout_offering: workout_offering,
          workout_score: workout_score,
          activity: 'lti_launch',
          user_agent: 'CustomTestBrowser/1.0',
          lti_launch: true
        )
      )

      request.env['HTTP_USER_AGENT'] = 'CustomTestBrowser/1.0'
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

    context "with views rendered" do
      render_views

      before do
        allow(instructor).to receive_message_chain(:global_role, :can_edit_system_configuration?).and_return(false)
      end

      it "renders the activity_log template with the review link, without LTI column, and with LTI badge" do
        get :activity_log, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201',
          workout_score_id: '301'
        }

        expect(response.status).to eq(200)
        expect(response.body).to include('Back to Review')
        expect(response.body).to include('/courses/vt/cs1114/fall2026/review/')
        expect(response.body).not_to include('<th>LTI?</th>')
        expect(response.body).to include('<span class=\'badge\'>LTI</span>')
        expect(response.body).to include('<small title=\'Mozilla/5.0\'>Mozilla/5.0</small>')
      end

      it "renders code prompt answers in <pre> tags and MC answers as 'choice: A' under score" do
        exercise = double('Exercise', id: 42)
        ex_version = double('ExerciseVersion', exercise: exercise)

        coding_answer = double('CodingPromptAnswer', answer: "def foo\n  42\nend")
        pa_coding = double('PromptAnswer', specific: coding_answer)
        attempt_coding = double('Attempt',
          id: 501,
          submit_time: Time.zone.parse('2026-09-01 10:05:00'),
          score: 10.0,
          ip_address: '1.2.3.4',
          lti_launch: false,
          prompt_answers: [pa_coding],
          exercise_version: ex_version
        )

        choice_a = double('Choice', id: 1, multiple_choice_prompt: nil, position: 1)
        mc_answer = double('MultipleChoicePromptAnswer', prompt: nil, choices: [choice_a])
        pa_mc = double('PromptAnswer', specific: mc_answer, prompt: nil)
        attempt_mc = double('Attempt',
          id: 502,
          submit_time: Time.zone.parse('2026-09-01 10:10:00'),
          score: 5.0,
          ip_address: '1.2.3.4',
          lti_launch: true,
          prompt_answers: [pa_mc],
          exercise_version: ex_version
        )

        allow(Attempt).to receive(:where).with(workout_score: workout_score).and_return([attempt_coding, attempt_mc])

        get :activity_log, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201',
          workout_score_id: '301'
        }

        expect(response.status).to eq(200)
        expect(response.body).to include('<pre>def foo&#x000A;  42&#x000A;end</pre>').or include("<pre>def foo\n  42\nend</pre>")
        expect(response.body).to include('choice: A')
        expect(response.body).to include(
          "<a class=\"btn btn-default btn-xs\" href=\"/courses/vt/cs1114/fall2026/201/review/#{student.id}/42?attempt_id=501\">View</a>"
        )
        expect(response.body).to include(
          "<a class=\"btn btn-default btn-xs\" href=\"/courses/vt/cs1114/fall2026/201/review/#{student.id}/42?attempt_id=502\">View</a>"
        )
      end

      it "renders error alert for coding prompt answers when error is present" do
        exercise = double('Exercise', id: 42)
        ex_version = double('ExerciseVersion', exercise: exercise)

        coding_answer_with_error = double('CodingPromptAnswer',
          answer: "def foo\n  syntax error here",
          error: "SyntaxError: unexpected token\n  at line 2"
        )
        pa_error = double('PromptAnswer', specific: coding_answer_with_error)
        attempt_error = double('Attempt',
          id: 503,
          submit_time: Time.zone.parse('2026-09-01 10:15:00'),
          score: 0.0,
          ip_address: '1.2.3.4',
          lti_launch: false,
          prompt_answers: [pa_error],
          exercise_version: ex_version
        )

        allow(Attempt).to receive(:where).with(workout_score: workout_score).and_return([attempt_error])

        get :activity_log, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201',
          workout_score_id: '301'
        }

        expect(response.status).to eq(200)
        expect(response.body).to include("<div class='alert alert-danger' role='alert'>").or include('<div class="alert alert-danger" role="alert">')
        expect(response.body).to include('SyntaxError: unexpected token')
        expect(response.body).to include('<br>')
        expect(response.body).to include('at line 2')
      end
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
      allow(ActivityLog).to receive(:create).and_return(true)
    end

    describe "GET #show" do
      it "permits access to show workout status and review even when client IP or browser is restricted" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(false)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(false)

        request.env['REMOTE_ADDR'] = '10.0.0.1'
        request.env['HTTP_USER_AGENT'] = 'DisallowedBrowser/1.0'
        get :show, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@message)).to be_nil
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

      it "redirects to the first exercise for the attempt score when accessing practice" do
        first_ex = FactoryBot.build_stubbed(:exercise, id: 77)
        score = double('WorkoutScore', id: 301, closed?: false)
        allow(workout_offering).to receive(:score_for).with(student).and_return(score)
        allow(workout_offering).to receive(:active_score_for).with(student).and_return(score)
        allow(workout_offering).to receive(:can_be_practiced_by?).with(student).and_return(true)
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(true)

        expect(workout).to receive(:first_exercise).with(score).and_return(first_ex)

        get :practice, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response).to redirect_to(organization_workout_offering_exercise_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          workout_offering_id: '201',
          workout_score_id: 301,
          id: 77
        ))
      end

      it "does not create a WorkoutScore when IP is not allowed" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(false)
        expect(WorkoutScore).not_to receive(:new)
        expect(WorkoutScore).not_to receive(:create!)

        get :practice, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }
      end

      it "does not create a WorkoutScore when user agent is not allowed" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(false)
        expect(WorkoutScore).not_to receive(:new)
        expect(WorkoutScore).not_to receive(:create!)

        get :practice, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }
      end

      it "does not create a WorkoutScore and redirects when opening date has not arrived" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(true)
        allow(workout_offering).to receive(:opening_date_for).with(student).and_return(2.days.from_now)
        expect(WorkoutScore).not_to receive(:new)
        expect(WorkoutScore).not_to receive(:create!)

        get :practice, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response).to redirect_to(organization_workout_offering_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        ))
        expect(flash[:notice]).to eq('This workout is not yet open for practice.')
      end

      it "does not create a WorkoutScore and redirects when hard deadline has passed" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(true)
        allow(workout_offering).to receive(:hard_deadline_for).with(student).and_return(2.days.ago)
        expect(WorkoutScore).not_to receive(:new)
        expect(WorkoutScore).not_to receive(:create!)

        get :practice, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response).to redirect_to(organization_workout_offering_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        ))
        expect(flash[:notice]).to eq('The deadline has passed for this workout.')
      end

      it "does not create a WorkoutScore and redirects when attempts are exhausted" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(true)
        allow(workout_offering).to receive(:attempts_taken_for).with(student).and_return(2)
        allow(workout_offering).to receive(:attempts_left_for).with(student).and_return(0)
        expect(WorkoutScore).not_to receive(:new)
        expect(WorkoutScore).not_to receive(:create!)

        get :practice, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response).to redirect_to(organization_workout_offering_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        ))
        expect(flash[:notice]).to eq('You have completed all allowed attempts for this workout.')
      end

      it "redirects to exercise review path when score is closed, exercise is specified, and review is allowed" do
        closed_score = double('WorkoutScore', id: 301, closed?: true)
        exercise = double('Exercise', id: 45)
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(true)
        allow(workout_offering).to receive(:workout_policy).and_return(WorkoutPolicy.new(see_answers: true, no_review_before_close: false))
        allow(WorkoutScore).to receive(:find_by).with(id: '301').and_return(closed_score)
        allow(Exercise).to receive(:find_by).with(id: '45').and_return(exercise)

        get :practice, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201',
          exercise_id: '45',
          workout_score_id: '301'
        }

        expect(response).to redirect_to(organization_workout_offering_exercise_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          workout_offering_id: '201',
          id: 45,
          workout_score_id: 301
        ))
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

    describe "POST #start_attempt" do
      let(:first_exercise) { FactoryBot.build_stubbed(:exercise, id: 55) }

      before do
        allow(workout).to receive(:first_exercise).and_return(first_exercise)
        allow(workout.exercises).to receive(:count).and_return(3)
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(true)
      end

      it "creates a subsequent WorkoutScore with incremented attempt_number and redirects to first exercise" do
        allow(workout_offering).to receive(:can_start_new_attempt?).with(student).and_return(true)
        allow(workout_offering).to receive(:active_score_for).with(student).and_return(nil)
        allow(workout_offering).to receive(:attempts_taken_for).with(student).and_return(1)
        allow(workout_offering).to receive(:attempts_left_for).with(student).and_return(1)

        expect(WorkoutScore).to receive(:create!).with(hash_including(
          user: student,
          workout_offering: workout_offering,
          workout: workout,
          attempt_number: 2
        )).and_return(double('WorkoutScore', id: 302))

        post :start_attempt, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response).to redirect_to(organization_workout_offering_exercise_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          workout_offering_id: '201',
          workout_score_id: 302,
          id: 55
        ))
      end

      it "passes the new attempt score to Workout#first_exercise to redirect to the attempt's sampled exercise" do
        allow(workout_offering).to receive(:can_start_new_attempt?).with(student).and_return(true)
        allow(workout_offering).to receive(:active_score_for).with(student).and_return(nil)
        allow(workout_offering).to receive(:attempts_taken_for).with(student).and_return(1)
        allow(workout_offering).to receive(:attempts_left_for).with(student).and_return(1)

        new_score = double('WorkoutScore', id: 302)
        allow(WorkoutScore).to receive(:create!).and_return(new_score)
        expect(workout).to receive(:first_exercise).with(new_score).and_return(first_exercise)

        post :start_attempt, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response).to redirect_to(organization_workout_offering_exercise_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          workout_offering_id: '201',
          workout_score_id: 302,
          id: 55
        ))
      end

      it "redirects to workout offering path with alert if can_start_new_attempt? is false" do
        allow(workout_offering).to receive(:can_start_new_attempt?).with(student).and_return(false)

        post :start_attempt, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response).to redirect_to(organization_workout_offering_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        ))
        expect(flash[:alert]).to include('cannot start a new attempt')
      end

      it "does not create a WorkoutScore when IP is not allowed" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(false)
        expect(WorkoutScore).not_to receive(:new)
        expect(WorkoutScore).not_to receive(:create!)

        post :start_attempt, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@message)).to include("network location")
      end

      it "does not create a WorkoutScore when user agent is not allowed" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(false)
        expect(WorkoutScore).not_to receive(:new)
        expect(WorkoutScore).not_to receive(:create!)

        post :start_attempt, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@message)).to include("requires a specific browser")
      end

      it "does not create a WorkoutScore and redirects when opening date has not arrived" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(true)
        allow(workout_offering).to receive(:opening_date_for).with(student).and_return(2.days.from_now)
        expect(WorkoutScore).not_to receive(:new)
        expect(WorkoutScore).not_to receive(:create!)

        post :start_attempt, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response).to redirect_to(organization_workout_offering_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        ))
        expect(flash[:notice]).to eq('This workout is not yet open for practice.')
      end

      it "does not create a WorkoutScore and redirects when hard deadline has passed" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(true)
        allow(workout_offering).to receive(:hard_deadline_for).with(student).and_return(2.days.ago)
        expect(WorkoutScore).not_to receive(:new)
        expect(WorkoutScore).not_to receive(:create!)

        post :start_attempt, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response).to redirect_to(organization_workout_offering_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        ))
        expect(flash[:notice]).to eq('The deadline has passed for this workout.')
      end

      it "does not create a WorkoutScore and redirects when attempts are exhausted" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(true)
        allow(workout_offering).to receive(:attempts_taken_for).with(student).and_return(1)
        allow(workout_offering).to receive(:attempts_left_for).with(student).and_return(0)
        expect(WorkoutScore).not_to receive(:new)
        expect(WorkoutScore).not_to receive(:create!)

        post :start_attempt, params: {
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        }

        expect(response).to redirect_to(organization_workout_offering_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        ))
        expect(flash[:notice]).to eq('You have completed all allowed attempts for this workout.')
      end
    end
  end

  describe "GET #review" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall2026') }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 10, name: 'Practice Workout') }
    let(:course_offering) { FactoryBot.build_stubbed(:course_offering, id: 101, course: course, term: term) }
    let(:workout_offering) { FactoryBot.build_stubbed(:workout_offering, id: 201, workout: workout, course_offering: course_offering) }
    let(:student) { FactoryBot.build_stubbed(:user) }
    let(:score1) { double('WorkoutScore', id: 301, attempt_number: 1, closed?: true, completed?: true, score: 10, started_at: Time.zone.now, updated_at: Time.zone.now, show_score?: true, scored_attempts: []) }
    let(:score2) { double('WorkoutScore', id: 302, attempt_number: 2, closed?: true, completed?: true, score: 20, started_at: Time.zone.now, updated_at: Time.zone.now, show_score?: true, scored_attempts: []) }

    before do
      allow(controller).to receive(:current_user).and_return(student)
      allow(controller).to receive(:authorize!).and_return(true)
      allow(User).to receive(:find_by).and_return(student)
      allow(WorkoutOffering).to receive(:find).with('201').and_return(workout_offering)
      allow(WorkoutOffering).to receive(:find_by).with(id: '201').and_return(workout_offering)
      allow(workout_offering).to receive(:scores_for).with(student).and_return([score1, score2])
      allow(workout_offering).to receive(:kept_workout_score_for).with(student).and_return(score2)
      allow(workout_offering).to receive(:latest_score_for).with(student).and_return(score2)
    end

    it "loads all scores and selects the requested attempt" do
      get :review, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        id: '201',
        review_user_id: student.id,
        workout_score_id: 301
      }

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@all_scores)).to eq([score1, score2])
      expect(controller.instance_variable_get(:@workout_score)).to eq(score1)
    end

    it "assigns @exs from attempt snapshot exercises when present" do
      assigned_ex = double('Exercise', id: 55, name: 'Assigned Ex')
      wse = double('WorkoutScoreExercise', exercise: assigned_ex)
      wse_relation = double('WorkoutScoreExercisesRelation', any?: true)
      allow(wse_relation).to receive(:includes).and_return([wse])
      allow(score1).to receive(:workout_score_exercises).and_return(wse_relation)

      get :review, params: {
        organization_id: 'vt',
        course_id: 'cs1114',
        term_id: 'fall2026',
        id: '201',
        review_user_id: student.id,
        workout_score_id: 301
      }

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@exs)).to eq([assigned_ex])
    end
  end
end
