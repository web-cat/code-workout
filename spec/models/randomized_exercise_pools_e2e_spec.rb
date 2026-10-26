require 'spec_helper'

RSpec.describe 'Randomized Exercise Pools End-to-End', type: :model do
  let(:creator) { FactoryBot.create(:user) }
  let(:student) { FactoryBot.create(:user) }
  let(:course_offering) do
    CourseOffering.first || begin
      org = Organization.first || Organization.create!(name: 'Virginia Tech Test', abbreviation: 'VTT', slug: 'vtt')
      c = Course.first || Course.create!(name: 'Intro CS Test', number: 'CS 1114', organization: org, slug: 'cs1114')
      t = Term.first || Term.create!(season: 'Fall', year: 2026)
      CourseOffering.create!(course: c, term: t, label: '001')
    end
  end

  # Create exercises for pool slots
  let(:single_ex) { FactoryBot.create(:coding_exercise, name: 'Single Ex 1') }
  let(:slot2_ex1) { FactoryBot.create(:coding_exercise, name: 'Pool 2 Candidate A') }
  let(:slot2_ex2) { FactoryBot.create(:coding_exercise, name: 'Pool 2 Candidate B') }
  let(:slot2_ex3) { FactoryBot.create(:coding_exercise, name: 'Pool 2 Candidate C') }

  let(:slot3_ex1) { FactoryBot.create(:coding_exercise, name: 'Pool 3 Candidate 1') }
  let(:slot3_ex2) { FactoryBot.create(:coding_exercise, name: 'Pool 3 Candidate 2') }
  let(:slot3_ex3) { FactoryBot.create(:coding_exercise, name: 'Pool 3 Candidate 3') }
  let(:slot3_ex4) { FactoryBot.create(:coding_exercise, name: 'Pool 3 Candidate 4') }

  def create_attempt(offering, student, attempt_number)
    WorkoutScore.create!(
      user: student,
      workout_offering: offering,
      workout: offering.workout,
      attempt_number: attempt_number,
      score: 0,
      exercises_completed: 0,
      exercises_remaining: offering.workout.exercises.count,
      started_at: Time.zone.now
    )
  end

  it 'handles complete lifecycle: authoring, attempt snapshotting, navigation, retake anti-duplication, and pool exhaustion' do
    # 1. Authoring: Create workout with mixed slots (1 single, 2 pools)
    pools_data = [
      {
        position: 1,
        select_count: 1,
        points: 5.0,
        exercise_ids: [single_ex.id]
      },
      {
        position: 2,
        select_count: 1,
        points: 10.0,
        exercise_ids: [slot2_ex1.id, slot2_ex2.id, slot2_ex3.id]
      },
      {
        position: 3,
        select_count: 2,
        points: 15.0,
        exercise_ids: [slot3_ex1.id, slot3_ex2.id, slot3_ex3.id, slot3_ex4.id]
      }
    ]

    workout = Workout.new(name: 'CS1 Midterm Workout', creator: creator)
    workout.update_or_create(
      name: 'CS1 Midterm Workout',
      pools: pools_data.to_json
    )

    expect(workout.persisted?).to be true
    expect(workout.exercise_pools.count).to eq(3)
    # Total points: (1 * 5) + (1 * 10) + (2 * 15) = 45.0
    expect(workout.total_points).to eq(45.0)

    # Offering setup allowing multiple attempts
    offering = WorkoutOffering.create!(
      workout: workout,
      course_offering: course_offering,
      workout_attempt_limit: 5,
      time_limit: 60,
      opening_date: 1.day.ago,
      soft_deadline: 1.week.from_now
    )

    # 2. Attempt 1: Snapshotting and Navigation
    score1 = create_attempt(offering, student, 1)
    expect(score1).not_to be_nil
    expect(score1.attempt_number).to eq(1)

    attempt1_exercises = score1.exercises
    # 1 from slot 1, 1 from slot 2, 2 from slot 3 = 4 exercises
    expect(attempt1_exercises.count).to eq(4)

    # First exercise is slot 1's exercise
    expect(workout.first_exercise(score1)).to eq(single_ex)

    # Navigation follows attempt snapshot sequence
    ex_order = attempt1_exercises.to_a
    expect(workout.next_exercise(ex_order[0], score1)).to eq(ex_order[1])
    expect(workout.next_exercise(ex_order[1], score1)).to eq(ex_order[2])
    expect(workout.next_exercise(ex_order[2], score1)).to eq(ex_order[3])
    # Next after last wraps to first
    expect(workout.next_exercise(ex_order[3], score1)).to eq(ex_order[0])

    slot2_picked_attempt1 = (score1.exercises & [slot2_ex1, slot2_ex2, slot2_ex3]).first
    slot3_picked_attempt1 = score1.exercises & [slot3_ex1, slot3_ex2, slot3_ex3, slot3_ex4]
    expect(slot3_picked_attempt1.size).to eq(2)

    # 3. Attempt 2: Anti-Duplication Sampling
    score2 = create_attempt(offering, student, 2)
    expect(score2).not_to be_nil
    expect(score2.attempt_number).to eq(2)
    expect(score2.exercises.count).to eq(4)

    # Slot 1 is single exercise, so it is always single_ex
    expect(score2.exercises).to include(single_ex)

    # Slot 2 had 3 candidates and 1 seen in attempt 1.
    # Attempt 2 MUST pick one of the 2 unseen candidates!
    slot2_unseen_candidates = [slot2_ex1, slot2_ex2, slot2_ex3] - [slot2_picked_attempt1]
    slot2_picked_attempt2 = (score2.exercises & [slot2_ex1, slot2_ex2, slot2_ex3]).first
    expect(slot2_unseen_candidates).to include(slot2_picked_attempt2)

    # Slot 3 had 4 candidates and 2 seen in attempt 1.
    # Attempt 2 MUST pick the remaining 2 unseen candidates!
    slot3_unseen_candidates = [slot3_ex1, slot3_ex2, slot3_ex3, slot3_ex4] - slot3_picked_attempt1
    slot3_picked_attempt2 = score2.exercises & [slot3_ex1, slot3_ex2, slot3_ex3, slot3_ex4]
    expect(slot3_picked_attempt2).to match_array(slot3_unseen_candidates)

    # 4. Attempt 3: Pool Exhaustion Graceful Handling
    # In slot 3, all 4 candidates have now been seen across attempt 1 and attempt 2.
    score3 = create_attempt(offering, student, 3)
    expect(score3).not_to be_nil
    expect(score3.attempt_number).to eq(3)
    expect(score3.exercises.count).to eq(4)

    slot3_picked_attempt3 = score3.exercises & [slot3_ex1, slot3_ex2, slot3_ex3, slot3_ex4]
    # Successfully sampled 2 distinct exercises from slot 3 without crashing or intra-attempt duplicates
    expect(slot3_picked_attempt3.uniq.size).to eq(2)
    expect(score3.exercises.uniq.size).to eq(4)

    # 5. Points calculation and rescoring
    expect(score3.total_points).to eq(45.0)
    expect(score3.points_for(single_ex)).to eq(5.0)
    expect(score3.points_for(slot2_picked_attempt2)).to be_nil # from attempt 2
    expect(score3.points_for(score3.exercises.second)).to eq(10.0)
  end

  it 'handles legacy 1-of-1 pool workouts seamlessly' do
    w = Workout.create!(name: 'Legacy Single Exercises Workout', creator: creator)
    p1 = ExercisePool.create!(workout: w, select_count: 1, points: 10.0, position: 1)
    ExercisePoolItem.create!(exercise_pool: p1, exercise: single_ex)
    p2 = ExercisePool.create!(workout: w, select_count: 1, points: 20.0, position: 2)
    ExercisePoolItem.create!(exercise_pool: p2, exercise: slot2_ex1)

    offering = WorkoutOffering.create!(
      workout: w,
      course_offering: course_offering,
      opening_date: 1.day.ago,
      soft_deadline: 1.week.from_now
    )

    score = create_attempt(offering, student, 1)
    expect(score.exercises).to eq([single_ex, slot2_ex1])
    expect(score.points_for(single_ex)).to eq(10.0)
    expect(score.points_for(slot2_ex1)).to eq(20.0)
    expect(score.total_points).to eq(30.0)
  end
end
