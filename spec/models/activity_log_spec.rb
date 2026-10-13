require 'spec_helper'

RSpec.describe ActivityLog, type: :model do
  self.use_transactional_tests = false

  let(:sample_ua) { "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }

  before(:each) do
    UserAgent.clear_memory_cache!
    described_class.delete_all
    UserAgent.delete_all
  end

  after(:each) do
    UserAgent.clear_memory_cache!
    described_class.delete_all
    UserAgent.delete_all
  end

  describe "user_agent association and virtual setter" do
    it "automatically creates and links a UserAgent record when assigning a string" do
      log = described_class.create!(
        activity: 'workout_view',
        ip_address: '127.0.0.1',
        user_agent: sample_ua
      )

      expect(log.user_agent_id).to be_present
      expect(log.user_agent).to be_a(UserAgent)
      expect(log.user_agent.raw_user_agent).to eq(sample_ua)
      expect(log.user_agent.browser_family).to eq('Chrome')
      expect(log.raw_user_agent).to eq(sample_ua)
      expect(log.user_agent.to_s).to eq(sample_ua)
    end

    it "reuses an existing UserAgent record for duplicate strings" do
      ua_record = UserAgent.find_or_create_by_raw(sample_ua)

      log = described_class.create!(
        activity: 'workout_view',
        ip_address: '127.0.0.1',
        user_agent: sample_ua
      )

      expect(log.user_agent_id).to eq(ua_record.id)
    end

    it "accepts direct assignment of a UserAgent model instance" do
      ua_record = UserAgent.find_or_create_by_raw(sample_ua)
      log = described_class.create!(
        activity: 'workout_view',
        ip_address: '127.0.0.1',
        user_agent: ua_record
      )

      expect(log.user_agent_id).to eq(ua_record.id)
      expect(log.user_agent).to eq(ua_record)
    end

    it "handles nil or blank user agent gracefully" do
      log = described_class.create!(
        activity: 'workout_view',
        ip_address: '127.0.0.1',
        user_agent: nil
      )

      expect(log.user_agent_id).to be_nil
      expect(log.user_agent).to be_nil
      expect(log.raw_user_agent).to be_nil
    end
  end
end
