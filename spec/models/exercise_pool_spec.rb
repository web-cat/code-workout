require 'spec_helper'

describe ExercisePool, type: :model do
  let(:workout) { FactoryBot.create(:workout) }
  let(:exercise1) { FactoryBot.create(:coding_exercise) }
  let(:exercise2) { FactoryBot.create(:coding_exercise) }

  describe "validations" do
    it "is valid with valid attributes" do
      pool = ExercisePool.new(workout: workout, select_count: 1, points: 5.0)
      expect(pool).to be_valid
    end

    it "requires a workout" do
      pool = ExercisePool.new(workout: nil, select_count: 1, points: 5.0)
      expect(pool).not_to be_valid
      expect(pool.errors[:workout]).to include("can't be blank")
    end

    it "requires select_count to be at least 1" do
      pool = ExercisePool.new(workout: workout, select_count: 0, points: 5.0)
      expect(pool).not_to be_valid
      expect(pool.errors[:select_count]).to include("must be greater than or equal to 1")
    end

    it "requires points to be non-negative" do
      pool = ExercisePool.new(workout: workout, select_count: 1, points: -2.0)
      expect(pool).not_to be_valid
      expect(pool.errors[:points]).to include("must be greater than or equal to 0")
    end
  end

  describe "acts_as_list positioning" do
    it "automatically assigns sequential positions within the workout scope" do
      pool1 = ExercisePool.create!(workout: workout, select_count: 1, points: 5.0)
      pool2 = ExercisePool.create!(workout: workout, select_count: 1, points: 10.0)

      expect(pool1.position).to eq(1)
      expect(pool2.position).to eq(2)
    end
  end

  describe "associations and item management" do
    it "associates candidate exercises through exercise_pool_items" do
      pool = ExercisePool.create!(workout: workout, select_count: 1, points: 5.0)
      item1 = ExercisePoolItem.create!(exercise_pool: pool, exercise: exercise1, position: 1)
      item2 = ExercisePoolItem.create!(exercise_pool: pool, exercise: exercise2, position: 2)

      expect(pool.exercises).to match_array([exercise1, exercise2])
    end

    it "prevents duplicate exercises in the same pool" do
      pool = ExercisePool.create!(workout: workout, select_count: 1, points: 5.0)
      ExercisePoolItem.create!(exercise_pool: pool, exercise: exercise1, position: 1)

      duplicate = ExercisePoolItem.new(exercise_pool: pool, exercise: exercise1, position: 2)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:exercise_id]).to include("is already in this exercise pool")
    end

    it "allows the same exercise in different pools" do
      pool1 = ExercisePool.create!(workout: workout, select_count: 1, points: 5.0)
      pool2 = ExercisePool.create!(workout: workout, select_count: 1, points: 5.0)

      item1 = ExercisePoolItem.create!(exercise_pool: pool1, exercise: exercise1, position: 1)
      item2 = ExercisePoolItem.new(exercise_pool: pool2, exercise: exercise1, position: 1)
      expect(item2).to be_valid
    end
  end

  describe "#single_exercise?" do
    it "returns true when select_count is 1 and pool has 1 exercise" do
      pool = ExercisePool.create!(workout: workout, select_count: 1, points: 5.0)
      ExercisePoolItem.create!(exercise_pool: pool, exercise: exercise1)
      expect(pool.single_exercise?).to be true
    end

    it "returns false when pool has multiple candidate exercises" do
      pool = ExercisePool.create!(workout: workout, select_count: 1, points: 5.0)
      ExercisePoolItem.create!(exercise_pool: pool, exercise: exercise1)
      ExercisePoolItem.create!(exercise_pool: pool, exercise: exercise2)
      expect(pool.single_exercise?).to be false
    end

    it "returns false when select_count > 1" do
      pool = ExercisePool.create!(workout: workout, select_count: 2, points: 5.0)
      ExercisePoolItem.create!(exercise_pool: pool, exercise: exercise1)
      ExercisePoolItem.create!(exercise_pool: pool, exercise: exercise2)
      expect(pool.single_exercise?).to be false
    end
  end

  describe "#total_points" do
    it "computes select_count * points" do
      pool = ExercisePool.new(select_count: 2, points: 7.5)
      expect(pool.total_points).to eq(15.0)
    end
  end
end
