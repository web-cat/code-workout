require 'spec_helper'

describe IpAccessFilter do
  describe ".allowed?" do
    it "allows any IP when rule is nil or empty" do
      expect(IpAccessFilter.allowed?(nil, '192.168.1.1')).to be true
      expect(IpAccessFilter.allowed?('', '192.168.1.1')).to be true
      expect(IpAccessFilter.allowed?('   ', '192.168.1.1')).to be true
      expect(IpAccessFilter.allowed?([], '192.168.1.1')).to be true
    end

    it "disallows when client IP is blank" do
      expect(IpAccessFilter.allowed?('192.168.1.1', nil)).to be false
      expect(IpAccessFilter.allowed?('192.168.1.1', '')).to be false
    end

    it "allows any IP when rule is 'any', 'all', '*', or 'unrestricted'" do
      expect(IpAccessFilter.allowed?('any', '192.168.1.1')).to be true
      expect(IpAccessFilter.allowed?('ALL', '10.0.0.1')).to be true
      expect(IpAccessFilter.allowed?('*', '172.16.0.5')).to be true
      expect(IpAccessFilter.allowed?('unrestricted', '8.8.8.8')).to be true
    end

    it "blocks all IPs when rule is 'none'" do
      expect(IpAccessFilter.allowed?('none', '192.168.1.1')).to be false
      expect(IpAccessFilter.allowed?('none', '127.0.0.1')).to be false
    end

    it "matches exact IP addresses" do
      expect(IpAccessFilter.allowed?('192.168.1.50', '192.168.1.50')).to be true
      expect(IpAccessFilter.allowed?('192.168.1.50', '192.168.1.51')).to be false
      expect(IpAccessFilter.allowed?('::1', '::1')).to be true
      expect(IpAccessFilter.allowed?('127.0.0.1', '127.0.0.1')).to be true
    end

    it "matches CIDR subnet masks" do
      expect(IpAccessFilter.allowed?('192.168.1.0/24', '192.168.1.10')).to be true
      expect(IpAccessFilter.allowed?('192.168.1.0/24', '192.168.2.10')).to be false
      expect(IpAccessFilter.allowed?('10.0.0.0/8', '10.250.1.1')).to be true
      expect(IpAccessFilter.allowed?('10.0.0.0/8', '11.0.0.1')).to be false
    end

    it "matches IPv6 CIDR" do
      expect(IpAccessFilter.allowed?('2001:db8::/32', '2001:db8:ffff::1')).to be true
      expect(IpAccessFilter.allowed?('2001:db8::/32', '2001:db9::1')).to be false
    end

    it "matches wildcard / glob patterns" do
      expect(IpAccessFilter.allowed?('128.173.*.*', '128.173.45.67')).to be true
      expect(IpAccessFilter.allowed?('128.173.*.*', '128.174.45.67')).to be false
      expect(IpAccessFilter.allowed?('192.168.1.*', '192.168.1.99')).to be true
      expect(IpAccessFilter.allowed?('192.168.1.*', '192.168.2.99')).to be false
    end

    it "matches IP ranges" do
      expect(IpAccessFilter.allowed?('192.168.1.10-192.168.1.20', '192.168.1.15')).to be true
      expect(IpAccessFilter.allowed?('192.168.1.10-192.168.1.20', '192.168.1.25')).to be false
    end

    it "matches multiple rules separated by commas, spaces, or newlines" do
      rule = "192.168.1.0/24, 10.0.0.0/8\n128.173.*.*"
      expect(IpAccessFilter.allowed?(rule, '192.168.1.5')).to be true
      expect(IpAccessFilter.allowed?(rule, '10.5.5.5')).to be true
      expect(IpAccessFilter.allowed?(rule, '128.173.1.2')).to be true
      expect(IpAccessFilter.allowed?(rule, '172.16.1.1')).to be false
    end

    it "matches array of rules" do
      rules = ['192.168.1.0/24', '10.0.0.1']
      expect(IpAccessFilter.allowed?(rules, '192.168.1.5')).to be true
      expect(IpAccessFilter.allowed?(rules, '10.0.0.1')).to be true
      expect(IpAccessFilter.allowed?(rules, '10.0.0.2')).to be false
    end

    it "handles client IP with port cleanly" do
      expect(IpAccessFilter.allowed?('192.168.1.50', '192.168.1.50:54321')).to be true
      expect(IpAccessFilter.allowed?('192.168.1.0/24', '192.168.1.50:54321')).to be true
    end

    it "handles malformed tokens safely without raising errors" do
      expect {
        expect(IpAccessFilter.allowed?('invalid-token, 192.168.1.1', '192.168.1.1')).to be true
        expect(IpAccessFilter.allowed?('invalid-token', '192.168.1.1')).to be false
      }.not_to raise_error
    end
  end
end
