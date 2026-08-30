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
    end

    it "assigns attempt, exercise_version, exercise, and max_points" do
      get :feedback_update, params: { att_id: 1, format: :js }
      expect(response.status).to eq(200)
      expect(controller.instance_variable_get(:@attempt)).to eq(mock_attempt)
      expect(controller.instance_variable_get(:@exercise_version)).to eq(mock_version)
      expect(controller.instance_variable_get(:@exercise)).to eq(mock_exercise)
      expect(controller.instance_variable_get(:@max_points)).to eq(50)
    end
  end
end
