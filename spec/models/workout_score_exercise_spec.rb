require 'spec_helper'

describe WorkoutScoreExercise, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:workout) { FactoryBot.create(:workout) }
  let(:workout_score) { FactoryBot.create(:workout_score, user: user, workout: workout) }
  let(:exercise) { FactoryBot.create(:coding_exercise) }
  let(:pool) { FactoryBot.create(:exercise_pool, workout: workout) }

  describe "validations" do
    it "is valid with valid attributes" do
      wse = WorkoutScoreExercise.new(
        workout_score: workout_score,
        exercise: exercise,
        exercise_pool: pool,
        position: 1,
        points: 5.0
      )
      expect(wse).to be_valid
    end

    it "requires workout_score" do
      wse = WorkoutScoreExercise.new(workout_score: nil, exercise: exercise, position: 1, points: 5.0)
      expect(wse).not_to be_valid
      expect(wse.errors[:workout_score]).to include("can't be blank")
    end

    it "requires exercise" do
      wse = WorkoutScoreExercise.new(workout_score: workout_score, exercise: nil, position: 1, points: 5.0)
      expect(wse).not_to be_valid
      expect(wse.errors[:exercise]).to include("can't be blank")
    end

    it "requires points to be non-negative" do
      wse = WorkoutScoreExercise.new(
        workout_score: workout_score,
        exercise: exercise,
        position: 1,
        points: -1.0
      )
      expect(wse).not_to be_valid
      expect(wse.errors[:points]).to include("must be greater than or equal to 0")
    end
  end

  describe "acts_as_list positioning" do
    it "maintains sequential order within workout_score scope" do
      exercise2 = FactoryBot.create(:coding_exercise)
      wse1 = WorkoutScoreExercise.create!(
        workout_score: workout_score,
        exercise: exercise,
        exercise_pool: pool,
        points: 5.0
      )
      wse2 = WorkoutScoreExercise.create!(
        workout_score: workout_score,
        exercise: exercise2,
        exercise_pool: pool,
        points: 5.0
      )

      expect(wse1.position).to eq(1)
      expect(wse2.position).to eq(2)
    end
  end
end
