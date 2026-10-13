require 'spec_helper'

RSpec.describe Error, type: :model do
  let(:sample_ua) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }
  let(:error) { described_class.new(class_name: 'RuntimeError', message: 'Test failure') }

  describe "user_agent association and setter" do
    it "automatically finds or creates a UserAgent record when assigning a string" do
      error.user_agent = sample_ua
      expect(error.user_agent).to be_a(UserAgent)
      expect(error.user_agent.raw_user_agent).to eq(sample_ua)
      expect(error.user_agent.browser_family).to eq('Chrome')
      expect(error.raw_user_agent).to eq(sample_ua)
      expect(error.user_agent.to_s).to eq(sample_ua)
    end

    it "accepts direct assignment of a UserAgent model instance" do
      ua_record = UserAgent.find_or_create_by_raw(sample_ua)
      error.user_agent = ua_record
      expect(error.user_agent).to eq(ua_record)
      expect(error.user_agent_id).to eq(ua_record.id)
    end

    it "handles nil user_agent gracefully" do
      error.user_agent = nil
      expect(error.user_agent).to be_nil
      expect(error.user_agent_id).to be_nil
      expect(error.raw_user_agent).to be_nil
    end
  end
end
