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
end
