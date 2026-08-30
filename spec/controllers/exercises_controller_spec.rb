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
end
