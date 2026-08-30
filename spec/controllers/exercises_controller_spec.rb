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
end

