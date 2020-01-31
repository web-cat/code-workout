# == Schema Information
#
# Table name: test_cases
#
#  id                :integer          not null, primary key
#  negative_feedback :text(65535)
#  weight            :float(24)        not null
#  description       :text(65535)
#  created_at        :datetime
#  updated_at        :datetime
#  coding_prompt_id  :integer          not null
#  input             :text(65535)      not null
#  expected_output   :text(65535)      not null
#  static            :boolean          default(FALSE), not null
#  screening         :boolean          default(FALSE), not null
#  example           :boolean          default(FALSE), not null
#  hidden            :boolean          default(FALSE), not null
#
# Indexes
#
#  index_test_cases_on_coding_prompt_id  (coding_prompt_id)
#

# This require is to prevent autoload circular dependencies, since
# TestCaseResult is used in one of the methods.

require 'test_case_result'


# =============================================================================
# Represents a test case used to evaluate a student's answer to a coding
# prompt.
#
class TestCase < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :coding_prompt, inverse_of: :test_cases
  has_many :test_case_results, inverse_of: :test_case, dependent: :destroy

  scope :only_examples, -> { where(example: true) }
  scope :only_hidden, -> { where(hidden: true) }
  scope :only_static, -> { where(static: true) }
  scope :only_dynamic, -> { where(static: false) }
  scope :only_screening, -> { where(screening: false) }


  #~ Validation ...............................................................

  validates :input, presence: true, if: :no_description?
  validates :expected_output, presence: true, if: :no_description?
  validates :coding_prompt, presence: true
  validates :weight, presence: true,
    numericality: { greater_than_or_equal_to: 0.0 }


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def no_description?
    self.description.blank?
  end


  # -------------------------------------------------------------
  def is_example?
    self.example
  end


  # -------------------------------------------------------------
  def apply_static_check(answer, code = nil)
    if !self.static
      return nil
    end

    if !code
      code = answer.without_comments
    end
    required_min_count = 1
    required_max_count = nil
    if self.expected_output.blank? ||
      self.expected_output =~ /^\s*(required|true|yes|present|found)\s*$/i
      required_min_count = 1
    elsif self.expected_output =~
      /^\s*(prohibited|false|no|absent|not\s*found)\s*$/i
      required_min_count = 0
      required_max_count = 0
    elsif self.expected_output =~ /^\s*([0-9]+)\s*$/
      required_min_count = $1.to_i
      required_max_count = required_min_count
    elsif self.expected_output =~ /^\s*{\s*([0-9]+)\s*,\s*([0-9]+)\s*}\s*$/
      required_min_count = $1.to_i
      required_max_count = $2.to_i
    elsif self.expected_output =~ /^\s*{\s*,\s*([0-9]+)\s*}\s*$/
      required_min_count = 0
      required_max_count = $1.to_i
    elsif self.expected_output =~ /^\s*{\s*([0-9]+)\s*,\s*}\s*$/
      required_min_count = $1.to_i
    end
    options = nil
    regex = self.input
    if regex =~ /^\s*loop(s?)\s*$/i
      regex = 'keywords:for,while,do'
    elsif regex =~ /^\s*list(s?)\s*$/i
      regex = 'classes:List,ArrayList,LinkedList'
    elsif regex =~ /^\s*map(s?)\s*$/i
      regex = 'classes:Map,HashMap,TreeMap'
    elsif regex =~ /^\s*set(s?)\s*$/i
      regex = 'classes:Set,HashSet,TreeSet'
    elsif regex =~ /^\s*array(s?)\s*$/i
      regex = '/\[[^\]]*\]/'
    elsif regex =~ /^\s*recursion\s*$/i
      regex = 'self method:' + self.coding_prompt.method_name
    end
    nresp = self.negative_feedback
    nresp_operator = 'use'
    if regex =~ /^\s*keyword(s?)\s*:\s*/
      regex = '\b(' + to_choices(regex, /^\s*keyword(s?)\s*:\s*/) + ')\b'
    elsif regex =~ /^\s*class(es)?\s*:\s*/
      regex = '\b(' + to_choices(regex, /^\s*class(es)?\s*:\s*/) + ')\b'
    elsif regex =~ /^\s*(?:(library|self)\s+)?method(s?)\s*:\s*/
      internal = ($1 == 'self')
      regex = regex.gsub(/\s*\([^\)]*\)/, '')
      regex = to_choices(regex, /^\s*(?:(library|self)\s+)?method(s?)\s*:\s*/) + ')\s*\('
      if internal
        regex = '\b((this|super)\s*\.\s*|)(' + regex
      else
        regex = '(?<!\bthis|\bsuper)\s*\.\s*(' + regex
      end
    elsif regex.start_with? '/'
      nresp_operator = 'contain'
      last = regex.rindex('/')
      if last < regex.length - 1
        options = regex[(last + 1)..-1]
      end
      regex = regex[1..last]
    end
    actual_count = 0
    first_occurrence_line = nil
    last_occurrence_line = nil
    if !code.blank?
      code.scan(Regexp.new(regex, options)) do |hit|
        actual_count += 1
        last_occurrence_line = $`.lines.count
        if first_occurrence_line.nil?
          first_occurrence_line = last_occurrence_line
        end
      end
    end
    if actual_count < required_min_count
      passed = false
      if nresp.blank?
        nresp = 'Answer must ' + nresp_operator + ' ' + self.input
        if required_min_count > 1
          nresp = nresp + ' at least ' + required_min_count + ' times'
        end
      end
    elsif !required_max_count.nil? && actual_count > required_max_count
      passed = false
      if nresp.blank?
        nresp = 'Answer cannot ' + nresp_operator + ' ' + self.input
        if required_max_count > 0
          nresp = "line #{last_occurrence_line}: " + nresp + ' more than ' +
            required_max_count + ' ' + 'time'.pluralize(required_max_count)
        else
          nresp = "line #{first_occurrence_line}: " + nresp
        end
      end
    else
      passed = true
    end

    tcr = TestCaseResult.new(
      test_case: self,
      user: answer.attempt.user,
      coding_prompt_answer: answer,
      pass: passed,
      feedback_line_no: first_occurrence_line
    )
    if !passed
      tcr.execution_feedback = nresp
    end
    tcr.save!
    return (!passed && self.screening) ? nresp : nil
  end


  # -------------------------------------------------------------
  def display_description(pass = true)
    result = self.description
    if self.hidden?
      result = 'hidden'
    end
    # if result == 'example'
      # result = ''
    # elsif !result.blank? && result.start_with?('example:')
      # result = result.sub(/^example:\s*/, '')
    # end
    if result.blank?
      inp = self.input
      if self.static
        result = inp
      else
        if !inp.blank?
          inp.gsub!(/new\s+[a-zA-Z0-9]+(\s*\[\s*\])+\s*/, '')
        end
        result = coding_prompt.method_name + '(' + inp + ')'
      end
      if pass
        outp = self.expected_output
        if !outp.blank?
          outp.gsub!(/new\s+[a-zA-Z0-9]+(\s*\[\s*\])+\s*/, '')
        end
        result += ' -> ' + outp
      end
    end
    result
  end


  # -------------------------------------------------------------
  def record_result(answer, test_results_array)
    tcr = TestCaseResult.new(
      test_case: self,
      user: answer.attempt.user,
      coding_prompt_answer: answer,
      pass: (test_results_array.length == 8 && test_results_array[7].to_i == 1)
      )
    if !self.negative_feedback.blank?
      tcr.execution_feedback = self.negative_feedback
    else
      # This logic is somewhat Java-specific, and needs to be refactored
      # to better support other languages.
      if !test_results_array[5].blank?
        exception_name = test_results_array[5].sub(/^.*\./, '')
        if !(['AssertionFailedError',
          'AssertionError',
          'ComparisonFailure',
          'ReflectionSupportError'].include?(exception_name) ||
          (exception_name == 'Exception' &&
          test_results_array[6].start_with?('test timed out'))) ||
          test_results_array[6].blank? ||
          "null" == test_results_array[6]
          tcr.execution_feedback = exception_name
        end
      end
      if !test_results_array[6].blank? && 'null' != test_results_array[6]
        if !tcr.execution_feedback.blank?
          tcr.execution_feedback += ': '
        else
          tcr.execution_feedback = ''
        end
        if test_results_array[6].start_with? 'test timed out'
          test_results_array[6].sub!(/^test /, '')
          test_results_array[6].sub!('000 milli', ' ')
        end
        tcr.execution_feedback += test_results_array[6].sub(/^\w/, &:upcase)
      end
      if tcr.execution_feedback.blank?
        tcr.execution_feedback = 'did not meet expectations'
      end
    end
    tcr.save!

    # Return weighted score for this test result
    tcr.pass? ? self.weight : 0.0
  end


  # -------------------------------------------------------------
  def to_code(language)
    inp = self.input
    if !inp.blank?
      # TODO: need to fix this to handle nested parens appropriately
      inp.gsub!(/map\([^()]*\)/) do |map_expr|
        map_expr.split(/"/).map.with_index{ |x, i|
          if i % 2 == 0
            x.gsub(/\s*=(>?)\s*/, ', ')
          else
            x
          end
        }.join('"')
      end
    end
    TEST_METHOD_TEMPLATES[language] % {
      id: self.id.to_s,
      method_name: coding_prompt.method_name,
      class_name: coding_prompt.class_name,
      input: inp,
      expected_output: self.expected_output,
      negative_feedback: self.negative_feedback,
      array: ((self.expected_output.start_with?('new ') &&
        self.expected_output.include?('[]')) ||
        self.expected_output.start_with?('array(')) ? 'Array' : ''
    }
  end


  # -------------------------------------------------------------
  def parse_description_specifier(desc)
    desc.strip! if !desc.blank?
    if !desc.blank?
      if desc.sub!(/^((?:(?:example|hidden|static|screening)\s*:\s*)+)(.*)$/i, "\\2")
        modifiers = $1
        if modifiers =~ /example/i
          self.example = true
        end
        if modifiers =~ /hidden/i
          self.hidden = true
        end
        if modifiers =~ /static/i
          self.static = true
        end
        if modifiers =~ /screening/i
          self.screening = true
        end
      end
      if desc == 'example'
        self.example = true
      elsif desc == 'hidden'
        self.hidden = true
      elsif desc == 'static'
        self.static = true
      elsif desc == 'screening'
        self.screening = true
      elsif !desc.blank?
        self.description = desc
      end
    end
  end


  # -------------------------------------------------------------
  def parse_negative_feedback_specifier(nfb)
    nfb.strip! if !nfb.blank?
    if !nfb.blank?
      if nfb.sub!(/^((?:(?:screening)\s*:\s*)+)(.*)$/i, "\2")
        self.screening = true
      end
      if nfb == 'screening'
        self.screening = true
      elsif !nfb.blank?
        self.negative_feedback = nfb
      end
    end
  end


  #~ Private instance methods .................................................
  private

  def to_choices(str, regex)
    str.sub(regex, '').tr(',', ' ').strip.split(/\s+/).uniq.join('|')
  end


    TEST_METHOD_TEMPLATES = {
      'Ruby' => <<RUBY_TEST,
  def test%{id}
    assert_equal(%{expected_output}, @@subject.%{method_name}(%{input}), "%{negative_feedback}")
  end

RUBY_TEST
      'Python' => <<PYTHON_TEST,
    def test%{id}(self):
        assert %{expected_output} == subject.%{method_name}(%{input}),"%{negative_feedback}"

PYTHON_TEST
      'Java' => <<JAVA_TEST,
    @Test
    public void test_%{id}()
    {
        assertEquals(
          "%{negative_feedback}",
          %{expected_output},
          subject.%{method_name}(%{input}));
    }
JAVA_TEST
      'C++' => <<CPP_TEST
    void test%{id}()
    {
        TSM_ASSERT_EQUALS(
          "%{negative_feedback}",
          %{expected_output},
          subject.%{method_name}(%{input}));
    }
CPP_TEST
    }

end
