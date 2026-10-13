require 'spec_helper'

RSpec.describe UserAgent, type: :model do
  self.use_transactional_tests = false

  let(:cldb_ua) { "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 CLDB/2.1.2.04" }
  let(:cmac_ua) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 CMAC/2.1.2.04" }
  let(:classic_ldb_ua) { "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36 LockDown Browser/2.0.7.02" }
  let(:seb_ua) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) SEB/3.2.0" }
  let(:safe_exam_browser_ua) { "Mozilla/5.0 (Windows NT 10.0; Win64; x64) SafeExamBrowser/3.1" }
  let(:chrome_win_ua) { "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }
  let(:firefox_mac_ua) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0" }
  let(:safari_mac_ua) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15" }
  let(:edge_win_ua) { "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0" }
  let(:claude_ua) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Claude/2.9939.4 Chrome/152.0.7977.130 Safari/537.36" }
  let(:honorlock_ua) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.8010.50 Safari/537.36 Honorlock" }
  let(:import_script_ua) { "Classroom personal-study import" }

  before(:each) do
    described_class.clear_memory_cache!
    described_class.delete_all
  end

  after(:each) do
    described_class.clear_memory_cache!
    described_class.delete_all
  end

  describe "validations and callbacks" do
    it "requires raw_user_agent" do
      record = described_class.new(raw_user_agent: nil)
      expect(record).not_to be_valid
      expect(record.errors[:raw_user_agent]).to be_present
    end

    it "automatically generates user_agent_hash on validation" do
      record = described_class.new(raw_user_agent: chrome_win_ua)
      expect(record.user_agent_hash).to be_nil
      record.valid?
      expect(record.user_agent_hash).to eq(Digest::SHA256.hexdigest(chrome_win_ua))
    end

    it "enforces uniqueness on user_agent_hash" do
      described_class.create!(raw_user_agent: chrome_win_ua)
      duplicate = described_class.new(raw_user_agent: chrome_win_ua)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_agent_hash]).to be_present
    end
  end

  describe ".find_or_create_by_raw" do
    it "returns nil for blank input" do
      expect(described_class.find_or_create_by_raw(nil)).to be_nil
      expect(described_class.find_or_create_by_raw("   ")).to be_nil
    end

    it "creates a new record when seen for the first time" do
      expect {
        record = described_class.find_or_create_by_raw(chrome_win_ua)
        expect(record).to be_persisted
        expect(record.raw_user_agent).to eq(chrome_win_ua)
      }.to change(described_class, :count).by(1)
    end

    it "deduplicates and returns the existing record on subsequent calls" do
      first = described_class.find_or_create_by_raw(chrome_win_ua)
      expect {
        second = described_class.find_or_create_by_raw("  #{chrome_win_ua}  ")
        expect(second.id).to eq(first.id)
      }.not_to change(described_class, :count)
    end

    it "uses in-memory cache to avoid redundant database queries" do
      record = described_class.find_or_create_by_raw(chrome_win_ua)
      # Expect no queries since hash is cached in memory
      expect(described_class).not_to receive(:find_by)
      cached = described_class.find_or_create_by_raw(chrome_win_ua)
      expect(cached.id).to eq(record.id)
    end
  end

  describe "classification" do
    context "LockDown Browser" do
      it "correctly classifies Windows CLDB agent" do
        record = described_class.create!(raw_user_agent: cldb_ua)
        expect(record.is_lockdown).to be true
        expect(record.is_seb).to be false
        expect(record.is_suspicious).to be false
        expect(record.browser_family).to eq("LockDown Browser")
        expect(record.browser_version).to eq("2.1.2.04")
        expect(record.os_family).to eq("Windows")
      end

      it "correctly classifies Mac CMAC agent" do
        record = described_class.create!(raw_user_agent: cmac_ua)
        expect(record.is_lockdown).to be true
        expect(record.browser_family).to eq("LockDown Browser")
        expect(record.browser_version).to eq("2.1.2.04")
        expect(record.os_family).to eq("macOS")
      end

      it "correctly classifies classic LockDown Browser agent" do
        record = described_class.create!(raw_user_agent: classic_ldb_ua)
        expect(record.is_lockdown).to be true
        expect(record.browser_family).to eq("LockDown Browser")
        expect(record.browser_version).to eq("2.0.7.02")
      end
    end

    context "Safe Exam Browser" do
      it "correctly classifies SEB agent" do
        record = described_class.create!(raw_user_agent: seb_ua)
        expect(record.is_seb).to be true
        expect(record.is_lockdown).to be false
        expect(record.browser_family).to eq("Safe Exam Browser")
        expect(record.browser_version).to eq("3.2.0")
        expect(record.os_family).to eq("macOS")
      end

      it "correctly classifies SafeExamBrowser agent" do
        record = described_class.create!(raw_user_agent: safe_exam_browser_ua)
        expect(record.is_seb).to be true
        expect(record.browser_family).to eq("Safe Exam Browser")
        expect(record.browser_version).to eq("3.1")
        expect(record.os_family).to eq("Windows")
      end
    end

    context "Suspicious user agents" do
      it "flags Claude Desktop app as suspicious" do
        record = described_class.create!(raw_user_agent: claude_ua)
        expect(record.is_suspicious).to be true
        expect(record.browser_family).to eq("Claude Desktop")
        expect(record.browser_version).to eq("2.9939.4")
        expect(record.os_family).to eq("macOS")
      end

      it "flags Honorlock extension as suspicious" do
        record = described_class.create!(raw_user_agent: honorlock_ua)
        expect(record.is_suspicious).to be true
        expect(record.browser_family).to eq("Honorlock")
      end

      it "flags automated import scripts as suspicious" do
        record = described_class.create!(raw_user_agent: import_script_ua)
        expect(record.is_suspicious).to be true
        expect(record.browser_family).to eq("Classroom Import Script")
      end

      it "flags python/curl clients as suspicious" do
        record = described_class.create!(raw_user_agent: "python-requests/2.28.1")
        expect(record.is_suspicious).to be true
      end
    end

    context "Standard browsers" do
      it "correctly identifies Chrome on Windows" do
        record = described_class.create!(raw_user_agent: chrome_win_ua)
        expect(record.browser_family).to eq("Chrome")
        expect(record.browser_version).to eq("120.0.0.0")
        expect(record.os_family).to eq("Windows")
        expect(record.is_lockdown).to be false
        expect(record.is_seb).to be false
        expect(record.is_suspicious).to be false
      end

      it "correctly identifies Firefox on macOS" do
        record = described_class.create!(raw_user_agent: firefox_mac_ua)
        expect(record.browser_family).to eq("Firefox")
        expect(record.browser_version).to eq("121.0")
        expect(record.os_family).to eq("macOS")
      end

      it "correctly identifies Safari on macOS" do
        record = described_class.create!(raw_user_agent: safari_mac_ua)
        expect(record.browser_family).to eq("Safari")
        expect(record.browser_version).to eq("17.2")
        expect(record.os_family).to eq("macOS")
      end

      it "correctly identifies Edge on Windows" do
        record = described_class.create!(raw_user_agent: edge_win_ua)
        expect(record.browser_family).to eq("Edge")
        expect(record.browser_version).to eq("120.0.0.0")
        expect(record.os_family).to eq("Windows")
      end
    end
  end

  describe "#display_name" do
    it "formats browser, version, and OS nicely" do
      record = described_class.create!(raw_user_agent: cldb_ua)
      expect(record.display_name).to eq("LockDown Browser 2.1.2.04 (Windows)")
    end

    it "formats Safari cleanly" do
      record = described_class.create!(raw_user_agent: safari_mac_ua)
      expect(record.display_name).to eq("Safari 17.2 (macOS)")
    end
  end

  describe "scopes" do
    it "filters by lockdown, seb, and suspicious" do
      ld = described_class.create!(raw_user_agent: cldb_ua)
      seb = described_class.create!(raw_user_agent: seb_ua)
      susp = described_class.create!(raw_user_agent: claude_ua)
      norm = described_class.create!(raw_user_agent: chrome_win_ua)

      expect(described_class.lockdown).to contain_exactly(ld)
      expect(described_class.seb).to contain_exactly(seb)
      expect(described_class.suspicious).to contain_exactly(susp)
      expect(described_class.by_browser("Chrome")).to contain_exactly(norm)
      expect(described_class.by_os("Windows")).to contain_exactly(ld, norm)
    end
  end
end
