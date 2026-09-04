require 'ipaddr'

module IpAccessFilter
  class << self
    # Determines if client_ip satisfies the given allowed_rule.
    #
    # allowed_rule can be:
    # - nil / empty / blank: returns true (no restrictions)
    # - 'any', 'all', '*', 'unrestricted': returns true
    # - 'none': returns false
    # - Array or String containing comma/space/semicolon/newline-delimited rules:
    #     e.g. "192.168.1.50, 10.0.0.0/8, 128.173.*.*"
    #
    # Patterns supported per token:
    # - 'any', 'all', '*', 'unrestricted': returns true
    # - Exact IP: "192.168.1.1", "::1"
    # - CIDR notation: "192.168.1.0/24", "2001:db8::/32"
    # - Netmask notation: "192.168.1.0/255.255.255.0"
    # - Wildcard / glob: "192.168.1.*", "128.173.*.*"
    # - IP ranges: "192.168.1.1-192.168.1.50"
    def allowed?(allowed_rule, client_ip)
      return true if allowed_rule.nil?
      return false if client_ip.blank?

      clean_client_ip = client_ip.to_s.strip
      # Remove port if present (e.g. 192.168.1.1:8080 or [::1]:8080)
      if clean_client_ip =~ /\A\[([a-fA-F0-9:]+)\](?::\d+)?\z/
        clean_client_ip = $1
      elsif clean_client_ip =~ /\A(\d{1,3}(?:\.\d{1,3}){3})(?::\d+)?\z/
        clean_client_ip = $1
      end

      tokens = extract_tokens(allowed_rule)
      return true if tokens.empty?

      # Parse client IP as IPAddr for CIDR/range comparisons
      client_ip_obj = begin
        IPAddr.new(clean_client_ip)
      rescue ArgumentError, IPAddr::Error
        nil
      end

      tokens.each do |token|
        return true if match_token?(token, clean_client_ip, client_ip_obj)
      end

      false
    end

    def extract_tokens(rule)
      if rule.is_a?(Array)
        rule.flat_map { |r| extract_tokens(r) }
      elsif rule.is_a?(String)
        rule.split(/[\s,;]+/).map(&:strip).reject(&:blank?)
      else
        []
      end
    end

    private

    def match_token?(token, client_ip, client_ip_obj)
      token_down = token.downcase

      # Keywords
      return true if ['any', 'all', '*', 'unrestricted'].include?(token_down)
      return false if token_down == 'none'

      # Glob / Wildcard pattern (e.g., 192.168.1.* or 128.173.*)
      if token.include?('*') || token.include?('?')
        return true if File.fnmatch?(token, client_ip, File::FNM_DOTMATCH)
      end

      # Range notation (e.g. 192.168.1.1-192.168.1.50)
      if token =~ /\A([^-]+)-([^-]+)\z/
        start_ip_str = $1.strip
        end_ip_str = $2.strip
        if client_ip_obj
          begin
            start_ip = IPAddr.new(start_ip_str)
            end_ip = IPAddr.new(end_ip_str)
            if start_ip.family == client_ip_obj.family && end_ip.family == client_ip_obj.family
              return true if (start_ip..end_ip).cover?(client_ip_obj)
            end
          rescue ArgumentError, IPAddr::Error
            # ignore range parse errors
          end
        end
      end

      # Exact string match
      return true if token == client_ip

      # IPAddr CIDR or exact IP match
      if client_ip_obj
        begin
          rule_ip = IPAddr.new(token)
          if rule_ip.family == client_ip_obj.family && rule_ip.include?(client_ip_obj)
            return true
          end
        rescue ArgumentError, IPAddr::Error
          # Not a valid IPAddr token, ignore
        end
      end

      false
    end
  end
end
