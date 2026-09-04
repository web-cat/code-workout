require 'spec_helper'

RSpec.describe UserAgentAccessFilter do
  describe ".allowed?" do
    let(:lockdown_ua) { "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36 LockDown Browser/2.0.7.02" }
    let(:seb_ua) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) SEB/3.2.0" }
    let(:chrome_ua) { "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }
    let(:firefox_ua) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0" }

    context "when allowed_rule is blank or nil" do
      it "allows any user agent when nil" do
        expect(described_class.allowed?(nil, chrome_ua)).to be true
        expect(described_class.allowed?(nil, "")).to be true
      end

      it "allows any user agent when empty string or whitespace" do
        expect(described_class.allowed?("", chrome_ua)).to be true
        expect(described_class.allowed?("   ", chrome_ua)).to be true
      end
    end

    context "when special keywords are used" do
      it "allows any browser for 'any', 'all', '*', 'unrestricted'" do
        %w[any all * unrestricted ANY All * UNRESTRICTED].each do |kw|
          expect(described_class.allowed?(kw, chrome_ua)).to be true
          expect(described_class.allowed?(kw, firefox_ua)).to be true
          expect(described_class.allowed?(kw, nil)).to be true
        end
      end

      it "blocks all browsers for 'none'" do
        expect(described_class.allowed?('none', lockdown_ua)).to be false
        expect(described_class.allowed?('none', seb_ua)).to be false
        expect(described_class.allowed?('none', chrome_ua)).to be false
      end
    end

    context "with substring matching" do
      it "matches single substring regardless of case" do
        expect(described_class.allowed?("LockDown Browser", lockdown_ua)).to be true
        expect(described_class.allowed?("lockdown browser", lockdown_ua)).to be true
        expect(described_class.allowed?("LOCKDOWN BROWSER", lockdown_ua)).to be true
        expect(described_class.allowed?("LockDown Browser", chrome_ua)).to be false
      end

      it "matches short markers like SEB" do
        expect(described_class.allowed?("SEB", seb_ua)).to be true
        expect(described_class.allowed?("seb", seb_ua)).to be true
        expect(described_class.allowed?("SEB", chrome_ua)).to be false
      end
    end

    context "with comma and delimited lists" do
      it "allows either browser when comma-separated" do
        rule = "LockDown Browser, SEB"
        expect(described_class.allowed?(rule, lockdown_ua)).to be true
        expect(described_class.allowed?(rule, seb_ua)).to be true
        expect(described_class.allowed?(rule, chrome_ua)).to be false
        expect(described_class.allowed?(rule, firefox_ua)).to be false
      end

      it "supports newline or semicolon separated rules" do
        rule = "LockDown Browser\nSEB; Respondus"
        expect(described_class.allowed?(rule, lockdown_ua)).to be true
        expect(described_class.allowed?(rule, seb_ua)).to be true
        expect(described_class.allowed?(rule, "Respondus/1.0")).to be true
        expect(described_class.allowed?(rule, chrome_ua)).to be false
      end

      it "supports array of rules" do
        rule = ["LockDown Browser", "SEB"]
        expect(described_class.allowed?(rule, lockdown_ua)).to be true
        expect(described_class.allowed?(rule, seb_ua)).to be true
        expect(described_class.allowed?(rule, chrome_ua)).to be false
      end
    end

    context "with wildcard patterns" do
      it "matches wildcards using fnmatch" do
        expect(described_class.allowed?("*LockDown*", lockdown_ua)).to be true
        expect(described_class.allowed?("*SEB*", seb_ua)).to be true
        expect(described_class.allowed?("*SEB*", chrome_ua)).to be false
      end
    end

    context "with regular expressions" do
      it "matches regex pattern enclosed in slashes" do
        expect(described_class.allowed?("/seb\\/\\d+\\.\\d+/i", seb_ua)).to be true
        expect(described_class.allowed?("/seb\\/\\d+\\.\\d+/i", chrome_ua)).to be false
      end
    end

    context "when client user agent is blank and restrictions exist" do
      it "rejects nil and empty client user agents" do
        expect(described_class.allowed?("LockDown Browser", nil)).to be false
        expect(described_class.allowed?("LockDown Browser", "")).to be false
        expect(described_class.allowed?("LockDown Browser", "   ")).to be false
      end
    end
  end
end
