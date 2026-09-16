# app/models/concerns/has_wrapper_code.rb
module HasWrapperCode
  extend ActiveSupport::Concern

  # -------------------------------------------------------------
  # Inserts code (such as a student's answer or reference code) into
  # the prompt's wrapper_code at the `___` placeholder, properly
  # matching the wrapper's indentation for multi-line code.
  def wrap_code(code_text)
    text = code_text.to_s
    return text if wrapper_code.blank?

    if (match = wrapper_code.match(/\b___\b/))
      leading_indent = placeholder_indent(match)

      indented_code = if !leading_indent.empty?
        text.gsub(/\r?\n(?!\z)/) { |nl| "#{nl}#{leading_indent}" }
      else
        text
      end

      # Use block form of sub so that backslashes in student code
      # are not interpreted as regex escape sequences (\1, \&, etc.)
      wrapper_code.sub(/\b___\b/) { indented_code }
    else
      puts 'ERROR: no answer insertion marker in wrapper code: ' + wrapper_code.to_s
      wrapper_code
    end
  end

  # -------------------------------------------------------------
  # Returns the count of newline characters in wrapper_code preceding
  # the line containing the `___` placeholder. Used for compiler error
  # line number adjustments.
  def pre_lines
    return 0 if wrapper_code.blank?

    if (match = wrapper_code.match(/\b___\b/))
      match.pre_match.count("\n")
    else
      0
    end
  end

  # -------------------------------------------------------------
  # Returns the leading indentation whitespace (spaces/tabs) on the line
  # where the `___` placeholder appears in wrapper_code.
  def placeholder_indent(match = nil)
    return '' if wrapper_code.blank?

    match ||= wrapper_code.match(/\b___\b/)
    if match
      pre = match.pre_match
      line_start = pre.rindex("\n") ? pre.rindex("\n") + 1 : 0
      line_prefix = pre[line_start..-1]
      line_prefix[/\A[ \t]*/] || ''
    else
      ''
    end
  end
end
