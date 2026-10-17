require 'spec_helper'

RSpec.describe Attempt, type: :model do
  let(:sample_ua) { "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 CLDB/2.1.2.04" }

  describe "user_agent association and virtual setter" do
    let(:attempt) { described_class.new }

    it "automatically finds or creates a UserAgent record when assigning a string" do
      attempt.user_agent = sample_ua
      expect(attempt.user_agent).to be_a(UserAgent)
      expect(attempt.user_agent.raw_user_agent).to eq(sample_ua)
      expect(attempt.user_agent.is_lockdown).to be true
      expect(attempt.user_agent.browser_family).to eq('LockDown Browser')
      expect(attempt.raw_user_agent).to eq(sample_ua)
      expect(attempt.user_agent.to_s).to eq(sample_ua)
    end

    it "accepts direct assignment of a UserAgent model instance" do
      ua_record = UserAgent.find_or_create_by_raw(sample_ua)
      attempt.user_agent = ua_record
      expect(attempt.user_agent).to eq(ua_record)
      expect(attempt.user_agent_id).to eq(ua_record.id)
    end

    it "handles nil user_agent gracefully" do
      attempt.user_agent = nil
      expect(attempt.user_agent).to be_nil
      expect(attempt.user_agent_id).to be_nil
      expect(attempt.raw_user_agent).to be_nil
    end
  end
end
