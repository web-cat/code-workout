require 'spec_helper'

describe WorkoutOffering, type: :model do
  describe "#can_be_practiced_by?" do
    let(:user) { FactoryBot.build_stubbed(:user, id: 1) }
    let(:course_offering) { FactoryBot.build_stubbed(:course_offering, id: 10) }
    let(:workout_offering) do
      FactoryBot.build_stubbed(
        :workout_offering,
        id: 20,
        course_offering: course_offering,
        opening_date: 2.days.ago,
        soft_deadline: 2.days.from_now,
        hard_deadline: 3.days.from_now
      )
    end

    before do
      allow(course_offering).to receive(:is_enrolled?).with(user).and_return(true)
      allow(course_offering).to receive(:is_staff?).with(user).and_return(false)
      allow(workout_offering).to receive(:workout_scores).and_return(double(where: double(last: nil), loaded?: false))
    end

    it "returns true when within open dates and hard deadline" do
      allow(workout_offering).to receive(:student_extensions).and_return([])
      expect(workout_offering.can_be_practiced_by?(user)).to be true
    end

    it "honors opening_date and hard_deadline from student_extensions" do
      extension = FactoryBot.build_stubbed(
        :student_extension,
        user: user,
        workout_offering: workout_offering,
        opening_date: 5.days.ago,
        hard_deadline: 7.days.from_now
      )
      allow(workout_offering).to receive(:student_extensions).and_return([extension])
      expect(workout_offering.can_be_practiced_by?(user)).to be true
    end

    it "returns true after soft deadline when hard_deadline is unset" do
      workout_offering.soft_deadline = 1.day.ago
      workout_offering.hard_deadline = nil
      allow(workout_offering).to receive(:student_extensions).and_return([])
      expect(workout_offering.can_be_practiced_by?(user)).to be true
    end
  end

  describe "#hard_deadline_for" do
    let(:user) { FactoryBot.build_stubbed(:user, id: 1) }
    let(:workout_offering) do
      FactoryBot.build_stubbed(
        :workout_offering,
        id: 20,
        soft_deadline: 1.day.ago,
        hard_deadline: nil
      )
    end

    it "returns nil when hard_deadline is unset, even if soft_deadline is set" do
      allow(workout_offering).to receive(:student_extensions).and_return([])
      expect(workout_offering.hard_deadline_for(user)).to be_nil
    end

    it "returns offering hard_deadline when set" do
      workout_offering.hard_deadline = 2.days.from_now
      allow(workout_offering).to receive(:student_extensions).and_return([])
      expect(workout_offering.hard_deadline_for(user)).to eq(workout_offering.hard_deadline)
    end

    it "overrides with student extension hard_deadline if present" do
      ext = FactoryBot.build_stubbed(
        :student_extension,
        user: user,
        workout_offering: workout_offering,
        hard_deadline: 5.days.from_now
      )
      allow(workout_offering).to receive(:student_extensions).and_return([ext])
      expect(workout_offering.hard_deadline_for(user)).to eq(ext.hard_deadline)
    end

    it "extends offering hard_deadline if student extension soft_deadline is later" do
      workout_offering.hard_deadline = 2.days.from_now
      ext = FactoryBot.build_stubbed(
        :student_extension,
        user: user,
        workout_offering: workout_offering,
        soft_deadline: 4.days.from_now,
        hard_deadline: nil
      )
      allow(workout_offering).to receive(:student_extensions).and_return([ext])
      expect(workout_offering.hard_deadline_for(user)).to eq(ext.soft_deadline)
    end
  end

  describe "#ip_allowed?" do
    let(:user) { FactoryBot.build_stubbed(:user, id: 1) }
    let(:course_offering) { FactoryBot.build_stubbed(:course_offering, id: 10) }
    let(:workout_offering) do
      FactoryBot.build_stubbed(
        :workout_offering,
        id: 20,
        course_offering: course_offering,
        allowed_ips: '192.168.1.0/24'
      )
    end

    before do
      allow(course_offering).to receive(:is_staff?).with(user).and_return(false)
      allow(user).to receive(:global_role).and_return(double(is_admin?: false))
      allow(workout_offering).to receive(:score_for).with(user).and_return(nil)
    end

    it "allows any IP when offering has no IP restrictions" do
      workout_offering.allowed_ips = nil
      allow(workout_offering).to receive(:student_extensions).and_return([])
      expect(workout_offering.ip_allowed?('203.0.113.5', user)).to be true
    end

    it "allows matching IP and disallows non-matching IP" do
      allow(workout_offering).to receive(:student_extensions).and_return([])
      expect(workout_offering.ip_allowed?('192.168.1.50', user)).to be true
      expect(workout_offering.ip_allowed?('10.0.0.1', user)).to be false
    end

    it "bypasses restrictions for course staff" do
      allow(course_offering).to receive(:is_staff?).with(user).and_return(true)
      expect(workout_offering.ip_allowed?('10.0.0.1', user)).to be true
    end

    it "bypasses restrictions for admins" do
      allow(user).to receive(:global_role).and_return(double(is_admin?: true))
      expect(workout_offering.ip_allowed?('10.0.0.1', user)).to be true
    end

    it "allows student extension to override with different IP subnet" do
      ext = FactoryBot.build_stubbed(
        :student_extension,
        user: user,
        workout_offering: workout_offering,
        allowed_ips: '10.0.0.0/8'
      )
      allow(workout_offering).to receive(:student_extensions).and_return([ext])
      expect(workout_offering.ip_allowed?('10.5.5.5', user)).to be true
      expect(workout_offering.ip_allowed?('192.168.1.50', user)).to be false
    end

    it "allows student extension with 'any' to completely remove restrictions" do
      ext = FactoryBot.build_stubbed(
        :student_extension,
        user: user,
        workout_offering: workout_offering,
        allowed_ips: 'any'
      )
      allow(workout_offering).to receive(:student_extensions).and_return([ext])
      expect(workout_offering.ip_allowed?('203.0.113.195', user)).to be true
    end

    it "short-circuits via workout_score last_ip_address without running IP filter" do
      workout_score = double('WorkoutScore', last_ip_address: '10.0.0.1')
      # Even though 10.0.0.1 is not in 192.168.1.0/24, if already cached as valid, it short-circuits
      expect(IpAccessFilter).not_to receive(:allowed?)
      expect(workout_offering.ip_allowed?('10.0.0.1', user, workout_score)).to be true
    end

    it "updates workout_score last_ip_address on successful evaluation of new IP" do
      workout_score = double('WorkoutScore', id: 99, last_ip_address: nil, persisted?: true)
      allow(workout_offering).to receive(:student_extensions).and_return([])
      expect(workout_score).to receive(:update_columns).with(last_ip_address: '192.168.1.50')
      expect(workout_offering.ip_allowed?('192.168.1.50', user, workout_score)).to be true
    end

    it "does NOT update workout_score last_ip_address on rejected evaluation" do
      workout_score = double('WorkoutScore', id: 99, last_ip_address: '192.168.1.10', persisted?: true)
      allow(workout_offering).to receive(:student_extensions).and_return([])
      expect(workout_score).not_to receive(:update_columns)
      expect(workout_offering.ip_allowed?('10.0.0.1', user, workout_score)).to be false
    end
  end

  describe "#user_agent_allowed?" do
    let(:course_offering) { FactoryBot.build_stubbed(:course_offering) }
    let(:workout_offering) do
      FactoryBot.build_stubbed(
        :workout_offering,
        course_offering: course_offering,
        allowed_user_agents: 'LockDown Browser, SEB'
      )
    end
    let(:user) { FactoryBot.build_stubbed(:user) }
    let(:lockdown_ua) { "Mozilla/5.0 (Windows NT 10.0; Win64; x64) LockDown Browser/2.0" }
    let(:seb_ua) { "Mozilla/5.0 (Macintosh) SEB/3.2.0" }
    let(:chrome_ua) { "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0" }

    before do
      allow(course_offering).to receive(:is_staff?).with(user).and_return(false)
      allow(user).to receive_message_chain(:global_role, :is_admin?).and_return(false)
    end

    it "returns true when workout offering has no user agent restrictions" do
      unrestricted_offering = FactoryBot.build_stubbed(:workout_offering, course_offering: course_offering, allowed_user_agents: nil)
      expect(unrestricted_offering.user_agent_allowed?(chrome_ua, user)).to be true
    end

    it "permits allowed user agent strings" do
      allow(workout_offering).to receive(:student_extensions).and_return([])
      expect(workout_offering.user_agent_allowed?(lockdown_ua, user)).to be true
      expect(workout_offering.user_agent_allowed?(seb_ua, user)).to be true
    end

    it "rejects disallowed user agent strings" do
      allow(workout_offering).to receive(:student_extensions).and_return([])
      expect(workout_offering.user_agent_allowed?(chrome_ua, user)).to be false
    end

    it "always allows course offering staff to bypass restrictions" do
      allow(course_offering).to receive(:is_staff?).with(user).and_return(true)
      expect(workout_offering.user_agent_allowed?(chrome_ua, user)).to be true
    end

    it "always allows global admins to bypass restrictions" do
      admin = FactoryBot.build_stubbed(:user)
      allow(admin).to receive_message_chain(:global_role, :is_admin?).and_return(true)
      allow(course_offering).to receive(:is_staff?).with(admin).and_return(false)
      expect(workout_offering.user_agent_allowed?(chrome_ua, admin)).to be true
    end

    it "does NOT allow global non-admin roles (e.g. instructors not in this offering) to bypass" do
      instructor_user = FactoryBot.build_stubbed(:user)
      allow(instructor_user).to receive_message_chain(:global_role, :is_admin?).and_return(false)
      allow(course_offering).to receive(:is_staff?).with(instructor_user).and_return(false)
      expect(workout_offering.user_agent_allowed?(chrome_ua, instructor_user)).to be false
    end

    it "allows student extension to override with different browser requirement" do
      ext = FactoryBot.build_stubbed(
        :student_extension,
        user: user,
        workout_offering: workout_offering,
        allowed_user_agents: 'Firefox'
      )
      allow(workout_offering).to receive(:student_extensions).and_return([ext])
      expect(workout_offering.user_agent_allowed?('Mozilla/5.0 Firefox/121.0', user)).to be true
      expect(workout_offering.user_agent_allowed?(lockdown_ua, user)).to be false
    end

    it "allows student extension with 'any' to completely remove browser restrictions" do
      ext = FactoryBot.build_stubbed(
        :student_extension,
        user: user,
        workout_offering: workout_offering,
        allowed_user_agents: 'any'
      )
      allow(workout_offering).to receive(:student_extensions).and_return([ext])
      expect(workout_offering.user_agent_allowed?(chrome_ua, user)).to be true
    end

    it "short-circuits via workout_score last_user_agent without running filter" do
      workout_score = double('WorkoutScore', last_user_agent: chrome_ua)
      expect(UserAgentAccessFilter).not_to receive(:allowed?)
      expect(workout_offering.user_agent_allowed?(chrome_ua, user, workout_score)).to be true
    end

    it "updates workout_score last_user_agent on successful evaluation of new user agent" do
      workout_score = double('WorkoutScore', id: 99, last_user_agent: nil, persisted?: true)
      allow(workout_offering).to receive(:student_extensions).and_return([])
      expect(workout_score).to receive(:update_columns).with(last_user_agent: lockdown_ua)
      expect(workout_offering.user_agent_allowed?(lockdown_ua, user, workout_score)).to be true
    end

    it "does NOT update workout_score last_user_agent on rejected evaluation" do
      workout_score = double('WorkoutScore', id: 99, last_user_agent: lockdown_ua, persisted?: true)
      allow(workout_offering).to receive(:student_extensions).and_return([])
      expect(workout_score).not_to receive(:update_columns)
      expect(workout_offering.user_agent_allowed?(chrome_ua, user, workout_score)).to be false
    end
  end
end
