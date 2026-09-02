module UserAgentAccessFilter
  class << self
    # Determines if client_user_agent satisfies the given allowed_rule.
    #
    # allowed_rule can be:
    # - nil / empty / blank: returns true (no restrictions)
    # - 'any', 'all', '*', 'unrestricted': returns true
    # - 'none': returns false
    # - Array or String containing comma/semicolon/newline-delimited rules:
    #     e.g. "LockDown Browser, SEB" or ["LockDown Browser", "Secure Exam Browser"]
    #
    # Patterns supported per token:
    # - 'any', 'all', '*', 'unrestricted': returns true
    # - 'none': blocks
    # - Substring matching (case-insensitive): e.g. "LockDown Browser", "SEB", "Respondus"
    # - Wildcard / glob patterns: e.g. "*LockDown*", "*SEB*"
    # - Regular expressions: e.g. "/lockdown.*browser/i"
    def allowed?(allowed_rule, client_user_agent)
      return true if allowed_rule.nil?

      tokens = extract_tokens(allowed_rule)
      return true if tokens.empty?

      # If unrestricted keyword is present anywhere, allow immediately
      return true if tokens.any? { |t| unrestricted_keyword?(t) }

      # If client user agent is missing but a restriction is enforced, disallow
      return false if client_user_agent.blank?

      clean_agent = client_user_agent.to_s.strip

      tokens.each do |token|
        next if none_keyword?(token)
        return true if match_token?(token, clean_agent)
      end

      false
    end

    def extract_tokens(rule)
      if rule.is_a?(Array)
        rule.flat_map { |r| extract_tokens(r) }
      elsif rule.is_a?(String)
        rule.split(/[\r\n,;]+/).map(&:strip).reject(&:blank?)
      else
        []
      end
    end

    private

    def unrestricted_keyword?(token)
      %w[any all * unrestricted].include?(token.to_s.strip.downcase)
    end

    def none_keyword?(token)
      token.to_s.strip.downcase == 'none'
    end

    def match_token?(token, client_user_agent)
      t = token.to_s.strip
      agent = client_user_agent.to_s.strip

      # Check for regex format /pattern/flags
      if t =~ %r{\A/(.+)/([imx]*)\z}
        pattern = $1
        flags = $2
        options = 0
        options |= Regexp::IGNORECASE if flags.include?('i')
        options |= Regexp::MULTILINE if flags.include?('m')
        options |= Regexp::EXTENDED if flags.include?('x')
        begin
          return true if agent =~ Regexp.new(pattern, options)
        rescue RegexpError
          # Fallback to literal matching if invalid regex
        end
      end

      # Wildcard match if contains * or ?
      if t.include?('*') || t.include?('?')
        return true if File.fnmatch?(t.downcase, agent.downcase, File::FNM_DOTMATCH)
      end

      # Substring match (case-insensitive)
      agent.downcase.include?(t.downcase)
    end
  end
end
