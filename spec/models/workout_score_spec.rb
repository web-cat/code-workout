require 'spec_helper'

describe WorkoutScore, type: :model do
  describe "#closed?" do
    let(:user) { FactoryBot.build_stubbed(:user, id: 1) }
    let(:workout_offering) { FactoryBot.build_stubbed(:workout_offering, id: 20) }
    let(:workout_score) do
      FactoryBot.build_stubbed(
        :workout_score,
        user: user,
        workout_offering: workout_offering,
        started_at: 10.minutes.ago
      )
    end

    before do
      allow(workout_offering).to receive(:time_limit_for).with(user).and_return(nil)
      allow(workout_offering).to receive(:hard_deadline_for).with(user).and_return(nil)
    end

    it "returns false when workout offering is nil" do
      workout_score.workout_offering = nil
      expect(workout_score.closed?).to be false
    end

    it "returns false when untimed and no hard deadline is set" do
      expect(workout_score.closed?).to be false
    end

    it "does not treat time_limit of 0 as closed" do
      allow(workout_offering).to receive(:time_limit_for).with(user).and_return(0)
      expect(workout_score.closed?).to be false
    end

    it "returns false when timed but within time limit" do
      allow(workout_offering).to receive(:time_limit_for).with(user).and_return(30)
      expect(workout_score.closed?).to be false
    end

    it "returns true when timed and past time limit" do
      allow(workout_offering).to receive(:time_limit_for).with(user).and_return(5)
      expect(workout_score.closed?).to be true
    end

    it "returns false when hard deadline is in the future" do
      allow(workout_offering).to receive(:hard_deadline_for).with(user).and_return(1.day.from_now)
      expect(workout_score.closed?).to be false
    end

    it "returns true when past hard deadline" do
      allow(workout_offering).to receive(:hard_deadline_for).with(user).and_return(1.minute.ago)
      expect(workout_score.closed?).to be true
    end
  end

  describe "last_user_agent association and setter" do
    let(:sample_ua) { "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 CLDB/2.1.2.04" }
    let(:ws) { described_class.new }

    it "automatically finds or creates a UserAgent record when assigning a string" do
      ws.last_user_agent = sample_ua
      expect(ws.last_user_agent).to be_a(UserAgent)
      expect(ws.last_user_agent.raw_user_agent).to eq(sample_ua)
      expect(ws.last_user_agent.is_lockdown).to be true
      expect(ws.raw_last_user_agent).to eq(sample_ua)
      expect(ws.last_user_agent.to_s).to eq(sample_ua)
    end

    it "accepts direct assignment of a UserAgent instance" do
      ua_record = UserAgent.find_or_create_by_raw(sample_ua)
      ws.last_user_agent = ua_record
      expect(ws.last_user_agent).to eq(ua_record)
      expect(ws.last_user_agent_id).to eq(ua_record.id)
    end

    it "handles nil last_user_agent gracefully" do
      ws.last_user_agent = nil
      expect(ws.last_user_agent).to be_nil
      expect(ws.last_user_agent_id).to be_nil
      expect(ws.raw_last_user_agent).to be_nil
    end
  end

  describe "attempt_number sequencing" do
    let(:ws1) { WorkoutScore.new(user_id: 1, workout_offering_id: 20, workout_id: 5) }
    let(:ws2) { WorkoutScore.new(user_id: 1, workout_offering_id: 20, workout_id: 5) }

    it "defaults attempt_number to 1 for the first score" do
      allow(WorkoutScore).to receive_message_chain(:where, :count).and_return(0)
      ws1.set_attempt_number
      expect(ws1.attempt_number).to eq(1)
    end

    it "automatically increments attempt_number for subsequent scores" do
      allow(WorkoutScore).to receive_message_chain(:where, :count).and_return(1)
      allow(WorkoutScore).to receive_message_chain(:where, :maximum).and_return(1)
      ws2.set_attempt_number
      expect(ws2.attempt_number).to eq(2)
    end
  end

  describe "#update_lti" do
    let(:user) { FactoryBot.build_stubbed(:user, id: 1) }
    let(:lms_instance) { FactoryBot.build_stubbed(:lms_instance, consumer_key: 'key', consumer_secret: 'secret') }
    let(:course_offering) { FactoryBot.build_stubbed(:course_offering, lms_instance: lms_instance) }
    let(:workout_offering) { FactoryBot.build_stubbed(:workout_offering, course_offering: course_offering) }
    let(:workout_score) do
      FactoryBot.build_stubbed(
        :workout_score,
        user: user,
        workout_offering: workout_offering,
        workout_id: 10,
        score: 40.0,
        lis_outcome_service_url: 'https://canvas.example.edu/api/grade',
        lis_result_sourcedid: '12345'
      )
    end

    it "posts the offering effective_score_for rather than the attempt score" do
      allow(workout_offering).to receive(:effective_score_for).with(user).and_return(95.0)
      allow(ExerciseWorkout).to receive_message_chain(:where, :sum).and_return(100.0)

      tp_mock = double('IMS::LTI::ToolProvider')
      expect(IMS::LTI::ToolProvider).to receive(:new).with(
        'key',
        'secret',
        hash_including('lis_outcome_service_url' => 'https://canvas.example.edu/api/grade', 'lis_result_sourcedid' => '12345')
      ).and_return(tp_mock)

      # Expect effective_score (95.0) / total (100.0) = 0.95, not attempt score (40.0)
      expect(tp_mock).to receive(:post_replace_result!).with(0.95)

      workout_score.update_lti
    end
  end

  describe "randomized exercise pools & attempt sampling" do
    let(:user) { FactoryBot.create(:user) }
    let(:workout) { FactoryBot.create(:workout) }
    let(:ex1) { FactoryBot.create(:coding_exercise, name: 'Ex 1') }
    let(:ex2) { FactoryBot.create(:coding_exercise, name: 'Ex 2') }
    let(:ex3) { FactoryBot.create(:coding_exercise, name: 'Ex 3') }
    let(:ex4) { FactoryBot.create(:coding_exercise, name: 'Ex 4') }

    let!(:pool1) do
      # Pool 1: 1 fixed exercise (k = 1, N = 1)
      p = ExercisePool.create!(workout: workout, select_count: 1, points: 10.0, position: 1)
      ExercisePoolItem.create!(exercise_pool: p, exercise: ex1, position: 1)
      p
    end

    let!(:pool2) do
      # Pool 2: 1 chosen from 2 candidates (k = 1, N = 2)
      p = ExercisePool.create!(workout: workout, select_count: 1, points: 20.0, position: 2)
      ExercisePoolItem.create!(exercise_pool: p, exercise: ex2, position: 1)
      ExercisePoolItem.create!(exercise_pool: p, exercise: ex3, position: 2)
      p
    end

    describe "#generate_attempt_exercises!" do
      it "automatically generates attempt exercises on create" do
        score = WorkoutScore.create!(user: user, workout: workout)
        expect(score.workout_score_exercises.count).to eq(2)
        expect(score.exercises_remaining).to eq(2)
        expect(score.exercises_completed).to eq(0)

        # Slot 1 must be ex1
        wse1 = score.workout_score_exercises.find_by(position: 1)
        expect(wse1.exercise).to eq(ex1)
        expect(wse1.points).to eq(10.0)

        # Slot 2 must be either ex2 or ex3
        wse2 = score.workout_score_exercises.find_by(position: 2)
        expect([ex2, ex3]).to include(wse2.exercise)
        expect(wse2.points).to eq(20.0)
      end

      it "avoids duplicate exercise selections on retakes when fresh candidates are available" do
        # Attempt 1
        score1 = WorkoutScore.create!(user: user, workout: workout)
        chosen1 = score1.workout_score_exercises.find_by(exercise_pool: pool2).exercise

        # Attempt 2 should pick the unseen candidate from pool2
        score2 = WorkoutScore.create!(user: user, workout: workout)
        chosen2 = score2.workout_score_exercises.find_by(exercise_pool: pool2).exercise

        other_candidate = (chosen1 == ex2 ? ex3 : ex2)
        expect(chosen2).to eq(other_candidate)
      end

      it "gracefully samples from seen candidates when pool size is exhausted" do
        score1 = WorkoutScore.create!(user: user, workout: workout)
        score2 = WorkoutScore.create!(user: user, workout: workout)

        # Attempt 3: All candidates for pool2 have been seen in prior attempts
        expect {
          score3 = WorkoutScore.create!(user: user, workout: workout)
          chosen3 = score3.workout_score_exercises.find_by(exercise_pool: pool2).exercise
          expect([ex2, ex3]).to include(chosen3)
        }.not_to raise_error
      end

      it "supports sampling multiple exercises from a pool (draw k from N where k > 1)" do
        pool3 = ExercisePool.create!(workout: workout, select_count: 2, points: 15.0, position: 3)
        ExercisePoolItem.create!(exercise_pool: pool3, exercise: ex2, position: 1)
        ExercisePoolItem.create!(exercise_pool: pool3, exercise: ex3, position: 2)
        ExercisePoolItem.create!(exercise_pool: pool3, exercise: ex4, position: 3)

        score = WorkoutScore.create!(user: user, workout: workout)
        pool3_exercises = score.workout_score_exercises.where(exercise_pool: pool3)
        expect(pool3_exercises.count).to eq(2)
        expect(pool3_exercises.map(&:points)).to eq([15.0, 15.0])
      end
    end

    describe "helper methods" do
      let(:score) { WorkoutScore.create!(user: user, workout: workout) }

      it "#points_for returns the attempt-specific points" do
        expect(score.points_for(ex1)).to eq(10.0)
      end

      it "#total_points returns sum of assigned exercise points" do
        expect(score.total_points).to eq(30.0)
      end

      it "#total_exercises returns count of assigned exercises" do
        expect(score.total_exercises).to eq(2)
      end

      it "Workout#first_exercise and #next_exercise respect the attempt snapshot" do
        assigned = score.workout_score_exercises.order(:position).map(&:exercise)
        first_ex = assigned.first
        second_ex = assigned.second

        expect(workout.first_exercise(score)).to eq(first_ex)
        expect(workout.next_exercise(first_ex, score)).to eq(second_ex)
        expect(workout.next_exercise(second_ex, score)).to eq(first_ex)
      end
    end
  end
end
