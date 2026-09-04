require 'spec_helper'

describe ExercisesController do
  describe "GET #index" do
    it "responds successfully and assigns @exercises" do
      get :index
      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@exercises)).not_to be_nil
    end

    context "when a user is logged in" do
      it "preloads attempts grouped by exercise version ID" do
        user = FactoryBot.build_stubbed(:user)
        allow(controller).to receive(:current_user).and_return(user)

        get :index
        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@attempts_by_version_id)).to be_a(Hash)
      end
    end
  end

  describe "GET #search" do
    context "when no exercises match" do
      it "redirects to exercises_path with an alert message" do
        get :search, params: { search: "nonexistent_term" }
        expect(response).to redirect_to(exercises_path)
        expect(flash[:alert]).to include("No exercises were found")
      end
    end

    context "when exercises match" do
      let(:mock_version) { double("ExerciseVersion", id: 42, prompts: []) }
      let(:mock_exercise) do
        double(
          "Exercise",
          id: 1,
          current_version_id: 42,
          current_version: mock_version,
          tags: [],
          languages: [],
          exercise_owners: [],
          exercise_collection: nil
        )
      end
      let(:mock_relation) { [mock_exercise] }

      before do
        allow(mock_relation).to receive(:includes).and_return(mock_relation)
        allow(Exercise).to receive(:search).and_return(mock_relation)
      end

      it "responds successfully and assigns @exs" do
        get :search, params: { search: "test" }
        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@exs)).to eq(mock_relation)
      end

      context "when a user is logged in" do
        it "preloads attempts grouped by exercise version ID" do
          user = FactoryBot.build_stubbed(:user)
          allow(controller).to receive(:current_user).and_return(user)

          get :search, params: { search: "test" }
          expect(response.status).to eq(200)
          expect(controller.instance_variable_get(:@attempts_by_version_id)).to be_a(Hash)
        end
      end
    end
  end

  describe "GET #practice" do
    let(:user) { FactoryBot.build_stubbed(:user, id: 10) }
    let(:exercise_version) { FactoryBot.build_stubbed(:exercise_version, id: 101) }
    let(:exercise) { FactoryBot.build_stubbed(:exercise, id: 1, current_version: exercise_version, current_version_id: 101) }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 5) }
    let(:workout_score) { FactoryBot.build_stubbed(:workout_score, id: 7, workout: workout, user: user) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(Exercise).to receive(:find).with('1').and_return(exercise)
      allow(Exercise).to receive(:find_by).with(id: '1').and_return(exercise)
      allow(exercise_version).to receive(:exercise).and_return(exercise)
      allow(exercise_version).to receive(:image_processing).and_return(true)
      allow(exercise_version).to receive(:file_processing).and_return([])
      allow(controller).to receive(:authorize!).and_return(true)
      allow(ActivityLog).to receive(:create).and_return(true)
    end

    it "preloads workout exercises and scored attempts for sidebar" do
      allow(Workout).to receive(:find).with('5').and_return(workout)
      allow(WorkoutScore).to receive_message_chain(:includes, :find).and_return(workout_score)
      allow(WorkoutScore).to receive(:find).with('7').and_return(workout_score)
      allow(workout_score).to receive(:attempts_left_for_exercise_version).and_return(nil)
      allow(workout_score).to receive(:previous_attempt_for).and_return(nil)

      attempt = double('Attempt', id: 50, exercise_version_id: 101)
      allow(workout_score).to receive(:scored_attempts).and_return([attempt])

      exercises_relation = double('WorkoutExercisesRelation', size: 3)
      allow(workout).to receive(:exercises).and_return(exercises_relation)
      allow(exercises_relation).to receive(:includes).with(
        { current_version: :prompts },
        :tags,
        :languages,
        :exercise_workouts
      ).and_return([exercise])

      get :practice, params: { id: '1', workout_id: '5', workout_score_id: '7' }

      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@workout_exercises)).not_to be_nil
      expect(controller.instance_variable_get(:@scoring_attempts_by_version_id)).to be_a(Hash)
      expect(controller.instance_variable_get(:@scoring_attempts_by_version_id)[101]).to eq([attempt])
    end
  end

  describe "IP access restrictions enforcement" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall2026') }
    let(:course_offering) { FactoryBot.build_stubbed(:course_offering, id: 101, course: course, term: term, label: 'Section 1') }
    let(:user) { FactoryBot.build_stubbed(:user, id: 10) }
    let(:exercise_version) { FactoryBot.build_stubbed(:exercise_version, id: 101) }
    let(:exercise) { FactoryBot.build_stubbed(:exercise, id: 1, current_version: exercise_version, current_version_id: 101) }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 5) }
    let(:workout_offering) do
      FactoryBot.build_stubbed(
        :workout_offering,
        id: 201,
        workout: workout,
        course_offering: course_offering,
        allowed_ips: '192.168.1.0/24'
      )
    end
    let(:workout_score) { FactoryBot.build_stubbed(:workout_score, id: 7, workout_offering: workout_offering, workout: workout, user: user) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(Exercise).to receive(:find).with('1').and_return(exercise)
      allow(Exercise).to receive(:find_by).with(id: '1').and_return(exercise)
      allow(WorkoutOffering).to receive(:find_by).with(id: '201').and_return(workout_offering)
      allow(WorkoutOffering).to receive(:find).with('201').and_return(workout_offering)
      allow(exercise_version).to receive(:exercise).and_return(exercise)
      allow(exercise_version).to receive(:image_processing).and_return(true)
      allow(exercise_version).to receive(:file_processing).and_return([])
      allow(ExerciseVersion).to receive(:find_by).with(id: '101').and_return(exercise_version)
      allow(workout).to receive(:contains?).with(exercise).and_return(true)
      allow(controller).to receive(:authorize!).and_return(true)
      allow(course_offering).to receive(:is_staff?).with(user).and_return(false)
      allow(workout_offering).to receive(:score_for).with(user).and_return(workout_score)
    end

    describe "GET #practice with workout_offering" do
      it "blocks access and logs practice_view_ip_blocked when IP is disallowed" do
        allow(workout_offering).to receive(:ip_allowed?).with('10.0.0.1', user, workout_score).and_return(false)

        expect(ActivityLog).to receive(:create).with(hash_including(
          user: user,
          exercise: exercise,
          workout_offering: workout_offering,
          activity: 'practice_view_ip_blocked',
          ip_address: '10.0.0.1'
        ))

        request.env['REMOTE_ADDR'] = '10.0.0.1'
        get :practice, params: { id: '1', workout_offering_id: '201' }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@message)).to include("10.0.0.1")
      end

      it "blocks access and logs practice_view_user_agent_blocked when browser user agent is disallowed" do
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).with('DisallowedBrowser/1.0', user, workout_score).and_return(false)

        expect(ActivityLog).to receive(:create).with(hash_including(
          user: user,
          exercise: exercise,
          workout_offering: workout_offering,
          activity: 'practice_view_user_agent_blocked',
          user_agent: 'DisallowedBrowser/1.0'
        ))

        request.env['HTTP_USER_AGENT'] = 'DisallowedBrowser/1.0'
        get :practice, params: { id: '1', workout_offering_id: '201' }

        expect(response.status).to eq(200)
        expect(controller.instance_variable_get(:@message)).to include("requires a specific browser")
      end
    end

    describe "PATCH #evaluate with workout_offering" do
      it "blocks attempt submission, logs attempt_ip_blocked, and redirects to error path" do
        allow(WorkoutScore).to receive_message_chain(:includes, :find).and_return(workout_score)
        allow(workout_offering).to receive(:ip_allowed?).with('10.0.0.1', user, workout_score).and_return(false)

        expect(ActivityLog).to receive(:create).with(hash_including(
          user: user,
          exercise: exercise,
          workout_offering: workout_offering,
          activity: 'attempt_ip_blocked',
          ip_address: '10.0.0.1'
        ))
        expect(exercise_version).not_to receive(:new_attempt)

        request.env['REMOTE_ADDR'] = '10.0.0.1'
        patch :evaluate, params: { id: '1', workout_offering_id: '201', exercise_version_id: '101' }

        expected_path = organization_workout_offering_error_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        )
        expect(response).to redirect_to(expected_path)
        expect(flash[:error]).to include("10.0.0.1")
      end

      it "blocks attempt submission, logs attempt_user_agent_blocked, and redirects to error path" do
        allow(WorkoutScore).to receive_message_chain(:includes, :find).and_return(workout_score)
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).with('DisallowedBrowser/1.0', user, workout_score).and_return(false)

        expect(ActivityLog).to receive(:create).with(hash_including(
          user: user,
          exercise: exercise,
          workout_offering: workout_offering,
          activity: 'attempt_user_agent_blocked',
          user_agent: 'DisallowedBrowser/1.0'
        ))
        expect(exercise_version).not_to receive(:new_attempt)

        request.env['HTTP_USER_AGENT'] = 'DisallowedBrowser/1.0'
        patch :evaluate, params: { id: '1', workout_offering_id: '201', exercise_version_id: '101' }

        expected_path = organization_workout_offering_error_path(
          organization_id: 'vt',
          course_id: 'cs1114',
          term_id: 'fall2026',
          id: '201'
        )
        expect(response).to redirect_to(expected_path)
        expect(flash[:error]).to include("requires a specific browser")
      end

      it "returns explicit error response when workout score is closed" do
        allow(WorkoutScore).to receive_message_chain(:includes, :find).and_return(workout_score)
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(true)
        allow(workout_score).to receive(:closed?).and_return(true)
        allow(workout_offering).to receive(:can_be_practiced_by?).and_return(false)

        expect(exercise_version).not_to receive(:new_attempt)

        patch :evaluate, params: { id: '1', workout_offering_id: '201', exercise_version_id: '101' }, format: :js
        expect(response.body).to include("The time limit or deadline for this workout has passed")
        expect(response.body).to include("$(\".btn-submit\").prop('disabled', true)")
      end

      it "returns explicit error response when attempts are exhausted" do
        allow(WorkoutScore).to receive_message_chain(:includes, :find).and_return(workout_score)
        allow(workout_offering).to receive(:ip_allowed?).and_return(true)
        allow(workout_offering).to receive(:user_agent_allowed?).and_return(true)
        allow(workout_score).to receive(:closed?).and_return(false)
        allow(user).to receive(:is_staff?).and_return(false)
        allow(workout_score).to receive(:attempts_left_for_exercise_version).and_return(0)

        expect(exercise_version).not_to receive(:new_attempt)

        patch :evaluate, params: { id: '1', workout_offering_id: '201', exercise_version_id: '101' }, format: :js
        expect(response.body).to include("You have exhausted all attempts for this exercise")
        expect(response.body).to include("$(\".btn-submit\").prop('disabled', true)")
      end
    end
  end
end
