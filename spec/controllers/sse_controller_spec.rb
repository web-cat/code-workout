require 'spec_helper'

RSpec.describe SseController, type: :controller do
  describe "GET feedback_update" do
    let(:mock_exercise) { double("Exercise", id: 10, experience: 50) }
    let(:mock_version) { double("ExerciseVersion", id: 20, exercise: mock_exercise, prompts: []) }
    let(:mock_attempt) do
      double(
        "Attempt",
        id: 1,
        exercise_version: mock_version,
        workout_score: nil,
        prompt_answers: []
      )
    end

    before do
      allow(Attempt).to receive_message_chain(:includes, :find_by).and_return(mock_attempt)
      allow(controller).to receive(:authorize_attempt_access!).and_return(true)
    end

    it "eager loads prompt_answers with :actable without causing association errors on MCQs" do
      expect(Attempt).to receive(:includes).with(
        { exercise_version: [:exercise, :prompts] },
        { workout_score: [{ workout: [:exercise_workouts, :exercises] }, :workout_offering] },
        { prompt_answers: :actable }
      ).and_return(double(find_by: mock_attempt))

      get :feedback_update, params: { att_id: 1, format: :js }
    end

    it "assigns attempt, exercise_version, exercise, and max_points" do
      get :feedback_update, params: { att_id: 1, format: :js }
      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@attempt)).to eq(mock_attempt)
      expect(controller.instance_variable_get(:@exercise_version)).to eq(mock_version)
      expect(controller.instance_variable_get(:@exercise)).to eq(mock_exercise)
      expect(controller.instance_variable_get(:@max_points)).to eq(50)
    end

    it "assigns @workout_score, @workout, and @workout_offering when workout_score is present" do
      mock_offering = double("WorkoutOffering", id: 99)
      mock_workout = double("Workout", id: 88, exercise_workouts: [])
      allow(mock_workout.exercise_workouts).to receive(:loaded?).and_return(false)
      allow(mock_workout.exercise_workouts).to receive_message_chain(:where, :first).and_return(nil)
      mock_score = double("WorkoutScore", id: 77, workout: mock_workout, workout_offering: mock_offering)

      allow(mock_attempt).to receive(:workout_score).and_return(mock_score)

      get :feedback_update, params: { att_id: 1, format: :js }
      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@workout_score)).to eq(mock_score)
      expect(controller.instance_variable_get(:@workout)).to eq(mock_workout)
      expect(controller.instance_variable_get(:@workout_offering)).to eq(mock_offering)
    end
  end

  describe "Authorization and IDOR Prevention" do
    let(:mock_attempt) { double("Attempt", id: 42, user_id: 100, feedback_ready: false, workout_score: nil, exercise_version: double(exercise: nil)) }

    it "returns 404 Not Found when attempt does not exist" do
      allow(Attempt).to receive_message_chain(:includes, :find_by).and_return(nil)
      get :feedback_update, params: { att_id: 9999, format: :js }
      expect(response.status).to eq(404)
    end

    it "denies unauthenticated actor attempting to access another user's attempt" do
      allow(Attempt).to receive_message_chain(:includes, :find_by).and_return(mock_attempt)
      allow(controller).to receive(:current_user).and_return(nil)
      allow(controller).to receive(:authorize!).with(:read, mock_attempt).and_raise(CanCan::AccessDenied.new("Not authorized!"))

      get :feedback_update, params: { att_id: 42, format: :js }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to be_present
    end

    it "allows guest practice when session[:student_drift_user_id] matches attempt user_id" do
      allow(Attempt).to receive_message_chain(:includes, :find_by).and_return(mock_attempt)
      allow(controller).to receive(:current_user).and_return(nil)
      session[:student_drift_user_id] = 100

      get :feedback_update, params: { att_id: 42, format: :js }
      expect(response.status).to eq(200)
    end

    it "allows authenticated user to view attempt when authorized by CanCan" do
      student = FactoryBot.build_stubbed(:user, id: 100)
      allow(controller).to receive(:current_user).and_return(student)
      allow(Attempt).to receive_message_chain(:includes, :find_by).and_return(mock_attempt)
      expect(controller).to receive(:authorize!).with(:read, mock_attempt).and_return(true)

      get :feedback_update, params: { att_id: 42, format: :js }
      expect(response.status).to eq(200)
    end

    it "enforces authorization in feedback_poll" do
      allow(Attempt).to receive(:find_by).with(id: '42').and_return(mock_attempt)
      allow(controller).to receive(:current_user).and_return(nil)
      allow(controller).to receive(:authorize!).with(:read, mock_attempt).and_raise(CanCan::AccessDenied.new("Not authorized!"))

      get :feedback_poll, params: { att_id: 42, format: :js }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to be_present
    end
  end
end
