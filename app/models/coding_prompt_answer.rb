# == Schema Information
#
# Table name: coding_prompt_answers
#
#  id            :integer          not null, primary key
#  answer        :text(65535)
#  error         :text(65535)
#  error_line_no :integer
#

# =============================================================================
# Represents one coding prompt answer in an exercise attempt.  In spirit,
# this is a subclass of PromptAnswer, and inherits all of the fields of
# PromptAnswer via acts_as (see the documentation on-line for the
# activerecord-acts_as gem).
#
class CodingPromptAnswer < ActiveRecord::Base

  #~ Relationships ............................................................

  acts_as :prompt_answer
  has_many :test_case_results,
    #-> { includes :test_case },
    -> { order('test_case_id ASC').includes(:test_case) },
    inverse_of: :coding_prompt_answer, dependent: :destroy


  #~ Validation ...............................................................

  # Note: there is no validates :answer, presence: true here, intentionally.
  # There may be cases where a user attempts an exercise but does not
  # answer all prompts, and that would constitute an empty answer. We
  # want to allow that, so do not add validations preventing it.


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def execute_static_tests
    result = nil
    code = self.without_comments
    self.test_cases.only_static.each do |test_case|
      this_result = test_case.apply_static_check(self, code)
      if !result && this_result
        result = this_result
      end
    end
    result
  end


  # -------------------------------------------------------------
  def without_comments
    result = answer
    lang = prompt.specific.language
    if lang
      regex = REMOVE_COMMENTS_REGEX[lang]
      if regex
        # Replace all comments with just the line endings in the
        # comments, in order to preserve line numbering
        result.gsub!(regex) do |cmt|
          cmt.scan(/\n/).join('')
        end
      end
    end
    return result
  end


  #~ Private instance methods .................................................
  private

  # This approach doesn't really work, since comment characters can
  # be embedded inside string literals. We can probably come up with
  # slightly better way of handling majority of string literal situations
  # without doing a full parse, but that'll wait for a while.
    REMOVE_COMMENTS_REGEX = {
      'Java' => /(\/\*([^*]|(\*+[^*\/]))*\*+\/)|(\/\/[^\r\n]*)/,
      'C++' =>  /(\/\*([^*]|(\*+[^*\/]))*\*+\/)|(\/\/[^\r\n]*)/,
      'Python' =>  /(#[^\r\n]*)/
    }


  # A Python example of handling string literals for this problem, from:
  # https://stackoverflow.com/questions/2319019/using-regex-to-remove-comments-from-source-files
  #
  # def remove_comments(string):
  #   pattern = r"(\".*?\"|\'.*?\')|(/\*.*?\*/|//[^\r\n]*$)"
  # # first group captures quoted strings (double or single)
  # # second group captures comments (//single-line or /* multi-line */)
  # regex = re.compile(pattern, re.MULTILINE|re.DOTALL)
  # def _replacer(match):
  #   # if the 2nd group (capturing comments) is not None,
  #   # it means we have captured a non-quoted (real) comment string.
  #   if match.group(2) is not None:
  #     return "" # so we will return empty to remove the comment
  #   else: # otherwise, we will return the 1st group
  #     return match.group(1) # captured quoted-string
  #   return regex.sub(_replacer, string)

  # Another regex (doesn't handle string literals) from:
  # https://stackoverflow.com/questions/5522733/removing-comments-in-javascript-using-ruby
  #
  # regexp_long = / # Match she-bang style C-comment
  #     \/\*!       # Opening delimiter.
  #     [^*]*\*+    # {normal*} Zero or more non-*, one or more *
  #     (?:         # Begin {(special normal*)*} construct.
  #       [^*\/]    # {special} a non-*, non-\/ following star.
  #       [^*]*\*+  # More {normal*}
  #     )*          # Finish "Unrolling-the-Loop"
  #     \/          # Closing delimiter.
  #     /x
  # result = subject.gsub(regexp_long, '')
end
