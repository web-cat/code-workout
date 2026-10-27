require 'spec_helper'

describe Workout, type: :model do
  describe ".find_by_id_or_name" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall2026') }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 42, name: 'Recursion Practice') }

    it "finds a workout by its numeric primary key ID" do
      allow(Workout).to receive(:find_by).with(id: '42').and_return(workout)

      found = Workout.find_by_id_or_name('42')
      expect(found).to eq(workout)
    end

    it "finds a workout by its exact name" do
      relation = double('WorkoutRelation')
      allow(Workout).to receive(:where).with('lower(name) = ?', 'recursion practice').and_return(relation)
      allow(relation).to receive(:first).and_return(workout)

      found = Workout.find_by_id_or_name('Recursion Practice')
      expect(found).to eq(workout)
    end

    it "finds a workout by its parameterized name slug" do
      relation = double('WorkoutOfferingsRelation')
      allow(WorkoutOffering).to receive(:joins).with(:course_offering).and_return(relation)
      allow(relation).to receive(:where).with(
        course_offerings: { course_id: course.id, term_id: term.id }
      ).and_return(relation)
      allow(relation).to receive(:includes).with(:workout).and_return([double(workout: workout)])

      found = Workout.find_by_id_or_name('recursion-practice', course, term)
      expect(found).to eq(workout)
    end
  end

  describe "#workout_offering_for" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, id: 1, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, id: 2, slug: 'fall2026') }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 42, name: 'Recursion Practice') }
    let(:student) { FactoryBot.build_stubbed(:user, id: 10) }
    let(:instructor) { FactoryBot.build_stubbed(:user, id: 20) }

    let(:section1) { FactoryBot.build_stubbed(:course_offering, id: 101, course: course, term: term) }
    let(:section2) { FactoryBot.build_stubbed(:course_offering, id: 102, course: course, term: term) }

    let(:offering1) { FactoryBot.build_stubbed(:workout_offering, id: 201, workout: workout, course_offering: section1) }
    let(:offering2) { FactoryBot.build_stubbed(:workout_offering, id: 202, workout: workout, course_offering: section2) }

    it "finds the student's enrolled section workout offering" do
      allow(student).to receive(:course_offerings_for_term).with(term, course).and_return([section2])
      allow(WorkoutOffering).to receive(:where).with(
        course_offering_id: [102],
        workout_id: workout.id
      ).and_return([offering2])

      found = workout.workout_offering_for(student, course, term)
      expect(found).to eq(offering2)
    end

    it "finds a staff managed section workout offering when user is instructor" do
      allow(instructor).to receive(:course_offerings_for_term).with(term, course).and_return([])
      allow(instructor).to receive(:managed_course_offerings).with(course: course, term: term).and_return([section1, section2])
      allow(WorkoutOffering).to receive(:where).with(
        course_offering_id: [101, 102],
        workout_id: workout.id
      ).and_return([offering1, offering2])

      found = workout.workout_offering_for(instructor, course, term)
      expect(found).to eq(offering1)
    end

    it "returns the first available offering for the course if user is unenrolled" do
      unenrolled_user = FactoryBot.build_stubbed(:user, id: 99)
      allow(unenrolled_user).to receive(:course_offerings_for_term).with(term, course).and_return([])
      allow(unenrolled_user).to receive(:managed_course_offerings).with(course: course, term: term).and_return([])
      offerings_relation = double('WorkoutOfferingsRelation')
      allow(WorkoutOffering).to receive(:joins).with(:course_offering).and_return(offerings_relation)
      allow(offerings_relation).to receive(:where).with(
        course_offerings: { course_id: course.id, term_id: term.id },
        workout_id: workout.id
      ).and_return(double(first: offering1))

      found = workout.workout_offering_for(unenrolled_user, course, term)
      expect(found).to eq(offering1)
    end
  end

  describe "#add_workout_offerings" do
    let(:workout) { FactoryBot.build(:workout) }
    let(:course_offering) { FactoryBot.build_stubbed(:course_offering, id: 101) }

    before do
      allow(CourseOffering).to receive(:find).with(101).and_return(course_offering)
      allow(WorkoutOffering).to receive(:find_by).and_return(nil)
      allow_any_instance_of(WorkoutOffering).to receive(:save!).and_return(true)
      allow_any_instance_of(WorkoutOffering).to receive(:rescore_all).and_return(true)
    end

    it "sets lms_assignment_url from offering hash" do
      common = { time_limit: nil, attempt_limit: nil, published: true }
      offerings_data = {
        101 => {
          'lms_assignment_url' => 'https://canvas.vt.edu/courses/1/assignments/10'
        }
      }

      wo = WorkoutOffering.new
      allow(WorkoutOffering).to receive(:new).and_return(wo)

      workout.add_workout_offerings(offerings_data, common)
      expect(wo.lms_assignment_url).to eq('https://canvas.vt.edu/courses/1/assignments/10')
    end

    it "sets lms_assignment_url when key is 'url'" do
      common = { time_limit: nil, attempt_limit: nil, published: true }
      offerings_data = {
        101 => {
          'url' => 'https://canvas.vt.edu/courses/1/assignments/20'
        }
      }

      wo = WorkoutOffering.new
      allow(WorkoutOffering).to receive(:new).and_return(wo)

      workout.add_workout_offerings(offerings_data, common)
      expect(wo.lms_assignment_url).to eq('https://canvas.vt.edu/courses/1/assignments/20')
    end
  end

  describe "exercise pool integration" do
    let(:workout) { FactoryBot.create(:workout) }
    let(:ex1) { FactoryBot.create(:coding_exercise, name: 'Ex 1') }
    let(:ex2) { FactoryBot.create(:coding_exercise, name: 'Ex 2') }
    let(:ex3) { FactoryBot.create(:coding_exercise, name: 'Ex 3') }

    it "computes total_points across pools as sum of (select_count * points)" do
      p1 = ExercisePool.create!(workout: workout, select_count: 1, points: 10.0, position: 1)
      p2 = ExercisePool.create!(workout: workout, select_count: 2, points: 15.0, position: 2)

      expect(workout.total_points).to eq(40.0)
    end

    it "computes num_exercises across pools as sum of select_count" do
      ExercisePool.create!(workout: workout, select_count: 1, points: 10.0, position: 1)
      p2 = ExercisePool.create!(workout: workout, select_count: 2, points: 15.0, position: 2)
      ExercisePoolItem.create!(exercise_pool: p2, exercise: ex1)
      ExercisePoolItem.create!(exercise_pool: p2, exercise: ex2)
      ExercisePoolItem.create!(exercise_pool: p2, exercise: ex3)

      # 3 candidate items in p2, but select_count is 2, so total num_exercises = 1 + 2 = 3
      expect(workout.num_exercises).to eq(3)
    end

    it "falls back to exercise_workouts for total_points when no pools exist" do
      w = FactoryBot.create(:workout)
      FactoryBot.create(:exercise_workout, workout: w, points: 5.0)
      FactoryBot.create(:exercise_workout, workout: w, points: 12.0)

      expect(w.total_points).to eq(17.0)
    end

    it "reports contains?(exercise) for pooled candidate exercises" do
      pool = ExercisePool.create!(workout: workout, select_count: 1, points: 5.0, position: 1)
      ExercisePoolItem.create!(exercise_pool: pool, exercise: ex1)

      expect(workout.contains?(ex1)).to be true
      expect(workout.contains?(ex2)).to be false
    end

    it "returns first_exercise and next_exercise from pools when no attempt score is provided" do
      p1 = ExercisePool.create!(workout: workout, select_count: 1, points: 5.0, position: 1)
      ExercisePoolItem.create!(exercise_pool: p1, exercise: ex1)
      p2 = ExercisePool.create!(workout: workout, select_count: 1, points: 5.0, position: 2)
      ExercisePoolItem.create!(exercise_pool: p2, exercise: ex2)

      expect(workout.first_exercise).to eq(ex1)
      expect(workout.next_exercise(ex1)).to eq(ex2)
    end

    describe "#update_or_create with pools" do
      it "creates exercise pools and candidate items from pools JSON" do
        pools_data = [
          {
            position: 1,
            select_count: 1,
            points: 5.0,
            exercise_ids: [ex1.id]
          },
          {
            position: 2,
            select_count: 1,
            points: 10.0,
            exercise_ids: [ex2.id, ex3.id]
          }
        ]

        w = Workout.new(name: 'Pooled Workout', creator: workout.creator)
        w.update_or_create(
          name: 'Pooled Workout',
          pools: pools_data.to_json
        )

        expect(w.persisted?).to be true
        expect(w.exercise_pools.count).to eq(2)
        
        first_pool = w.exercise_pools.find_by(position: 1)
        expect(first_pool.select_count).to eq(1)
        expect(first_pool.points).to eq(5.0)
        expect(first_pool.exercises).to eq([ex1])

        second_pool = w.exercise_pools.find_by(position: 2)
        expect(second_pool.select_count).to eq(1)
        expect(second_pool.points).to eq(10.0)
        expect(second_pool.exercises).to match_array([ex2, ex3])

        # Verifies synchronization to exercise_workouts
        expect(w.exercise_workouts.count).to eq(3)
        expect(w.exercise_workouts.map(&:exercise_id)).to match_array([ex1.id, ex2.id, ex3.id])
      end

      it "updates existing pools and reconciles removed candidate exercises" do
        p1 = ExercisePool.create!(workout: workout, select_count: 1, points: 5.0, position: 1)
        ExercisePoolItem.create!(exercise_pool: p1, exercise: ex1)
        ExercisePoolItem.create!(exercise_pool: p1, exercise: ex2)

        pools_data = [
          {
            id: p1.id,
            position: 1,
            select_count: 2,
            points: 8.0,
            exercise_ids: [ex2.id, ex3.id] # ex1 removed, ex3 added
          }
        ]

        workout.update_or_create(
          name: workout.name,
          pools: pools_data.to_json
        )

        p1.reload
        expect(p1.select_count).to eq(2)
        expect(p1.points).to eq(8.0)
        expect(p1.exercises).to match_array([ex2, ex3])
        expect(p1.exercises).not_to include(ex1)
      end

      it "falls back to creating 1-of-1 pools when only legacy exercises parameter is supplied" do
        w = Workout.new(name: 'Legacy Workout', creator: workout.creator)
        exercises_data = [
          { id: ex1.id, points: 4.0 },
          { id: ex2.id, points: 7.0 }
        ]

        w.update_or_create(
          name: 'Legacy Workout',
          exercises: exercises_data.to_json
        )

        expect(w.exercise_pools.count).to eq(2)
        expect(w.exercise_pools.map(&:points)).to match_array([4.0, 7.0])
        expect(w.exercise_pools.all? { |p| p.select_count == 1 }).to be true
      end
    end
  end
end

