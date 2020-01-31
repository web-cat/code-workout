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

    REMOVE_COMMENTS_REGEX = {
      'Java' => /(\/\*([^*]|(\*+[^*\/]))*\*+\/)|(\/\/[^\r\n]*)/
    }

end
