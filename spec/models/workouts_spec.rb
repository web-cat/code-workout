require 'spec_helper'

describe 'Workouts' do
  before :each do
    @workout = FactoryBot.create :workout_with_exercises
  end

  context "when getting the next exercise" do
    it "should get the first exercise if there is no current exercise" do
      ex = @workout.next_exercise(nil)
      expect(ex).to eq(@workout.exercises.first)
    end

    it "should get the next exercise if a current exercise is specified" do
      first_ex = @workout.exercises.first
      ex = @workout.next_exercise(first_ex)
      expect(ex).to eq(@workout.exercises[1])
    end

    it "should get the first exercise if the current exercise is not from this workout" do
      current_ex = FactoryBot.build(:coding_exercise)
      ex = @workout.next_exercise(current_ex)
      expect(ex).to eq(@workout.exercises.first)
    end
  end

  context "when updating or creating based on params" do
    before :all do
      @workout_params = {
        name: 'New name',
        is_public: false,
        removed_exercises: "[]",
        exercises: "[]"
      }
    end

    it "should update the name and public status with the specified parameters" do
      new_workout = @workout.update_or_create(@workout_params)

      expect(new_workout.name).to eq(@workout_params[:name])
      expect(new_workout.is_public).to be false
      expect(new_workout.description).to eq(@workout.description) # stays unchanged
    end

    it "should not change the workout's exercises if no changes are specified" do
      new_workout = @workout.update_or_create(@workout_params)

      expect(new_workout.exercises).to match(@workout.exercises)
    end

    it "should remove a specified exercise" do
      ew = @workout.exercise_workouts.first
      to_remove = ew.exercise

      params = {
        **@workout_params,
        removed_exercises: "[#{ew.id}]"
      }

      new_workout = @workout.update_or_create(params)
      expect(new_workout.exercises.count).to be(2)
      expect(new_workout.exercises).to_not include(to_remove)
    end

    it "should add the specified exercise while leaving the existing exercises intact" do
      old_exercises = @workout.exercises
      ex = FactoryBot.create :coding_exercise

      exercises = [{
        id: ex.id,
        points: 10
      }]

      params = {
        **@workout_params,
        exercises: JSON.dump(exercises)
      }

      new_workout = @workout.update_or_create(params)

      expect(new_workout.exercises.count).to be(4)
      expect(new_workout.exercises).to include(*old_exercises, ex)
    end
  end
end
