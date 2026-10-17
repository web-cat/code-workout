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
end
