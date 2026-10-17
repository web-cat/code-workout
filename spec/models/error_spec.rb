# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Error, type: :model do
  self.use_transactional_tests = false
  include ActiveSupport::Testing::TimeHelpers

  let(:sample_ua) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }
  let(:error) { described_class.new(class_name: 'RuntimeError', message: 'Test failure') }

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

  describe "fingerprinting" do
    it "generates a 64-character SHA-256 fingerprint" do
      err = described_class.new(
        class_name: 'NoMethodError',
        message: 'undefined method foo',
        trace: "app/models/user.rb:10\napp/controllers/home.rb:20\nconfig/routes.rb:30"
      )
      fp = err.generate_fingerprint
      expect(fp).to match(/\A[0-9a-f]{64}\z/)
    end

    it "normalizes dynamic hex memory addresses to produce the same fingerprint" do
      err1 = described_class.new(
        class_name: 'NoMethodError',
        message: 'undefined method `foo` for #<User:0x00007fa4c6dbb3f8>',
        trace: "app/models/user.rb:10\napp/controllers/home.rb:20"
      )
      err2 = described_class.new(
        class_name: 'NoMethodError',
        message: 'undefined method `foo` for #<User:0x00007fb18a9928d0>',
        trace: "app/models/user.rb:10\napp/controllers/home.rb:20"
      )
      expect(err1.generate_fingerprint).to eq(err2.generate_fingerprint)
    end

    it "produces different fingerprints for different error classes or top trace lines" do
      err1 = described_class.new(class_name: 'NoMethodError', message: 'fail', trace: "app/models/user.rb:10")
      err2 = described_class.new(class_name: 'ArgumentError', message: 'fail', trace: "app/models/user.rb:10")
      err3 = described_class.new(class_name: 'NoMethodError', message: 'fail', trace: "app/models/workout.rb:15")

      expect(err1.generate_fingerprint).not_to eq(err2.generate_fingerprint)
      expect(err1.generate_fingerprint).not_to eq(err3.generate_fingerprint)
    end
  end

  describe "duplicate aggregation on save" do
    let(:trace_lines) { "app/controllers/workouts_controller.rb:45\napp/models/workout.rb:120\nconfig/routes.rb:15" }

    it "saves first occurrence with count = 1 and last_seen_at set" do
      initial_time = Time.zone.parse('2026-10-17 10:00:00')
      created = nil
      travel_to(initial_time) do
        created = described_class.create!(
          class_name: 'RuntimeError',
          message: 'Connection timed out',
          trace: trace_lines,
          target: 'http://localhost:3000/workouts/1',
          user_agent: sample_ua
        )
      end

      expect(created.count).to eq(1)
      expect(created.fingerprint).to be_present
      expect(created.last_seen_at).to be_within(1.second).of(initial_time)
    end

    it "aggregates duplicate errors: does not create a new row, increments count, and updates context" do
      time1 = Time.zone.parse('2026-10-17 10:00:00')
      time2 = Time.zone.parse('2026-10-17 10:30:00')

      first_record = nil
      travel_to(time1) do
        first_record = described_class.create!(
          class_name: 'RuntimeError',
          message: 'Connection timed out for #<Server:0x00007fa1>',
          trace: trace_lines,
          target: 'http://localhost:3000/workouts/1',
          user_agent: sample_ua
        )
      end

      expect do
        travel_to(time2) do
          duplicate = described_class.new(
            class_name: 'RuntimeError',
            message: 'Connection timed out for #<Server:0x00007fa9>',
            trace: trace_lines,
            target: 'http://localhost:3000/workouts/2',
            referrer: 'http://localhost:3000/courses',
            params: '{"id"=>"2"}',
            user_agent: 'Firefox/115.0'
          )
          # save returns false because throw :abort cancels insertion
          expect(duplicate.save).to be false
        end
      end.not_to change(described_class, :count)

      first_record.reload
      expect(first_record.count).to eq(2)
      expect(first_record.last_seen_at).to be_within(1.second).of(time2)
      expect(first_record.target).to eq('http://localhost:3000/workouts/2')
      expect(first_record.referrer).to eq('http://localhost:3000/courses')
      expect(first_record.params).to eq('{"id"=>"2"}')
      expect(first_record.user_agent.browser_family).to eq('Firefox')
    end
  end
end
