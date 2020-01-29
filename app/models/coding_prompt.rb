# == Schema Information
#
# Table name: coding_prompts
#
#  id            :integer          not null, primary key
#  created_at    :datetime
#  updated_at    :datetime
#  class_name    :string(255)
#  wrapper_code  :text(65535)      not null
#  test_script   :text(65535)      not null
#  method_name   :string(255)
#  starter_code  :text(65535)
#  hide_examples :boolean          default(FALSE), not null
#

require 'fileutils'
require 'csv'

# =============================================================================
# Represents one coding prompt in an exercise.  In spirit,
# this is a subclass of Prompt, and inherits all of the fields of Prompt via
# acts_as (see the documentation on-line for the activerecord-acts_as
# gem).
#
class CodingPrompt < ActiveRecord::Base

  #~ Relationships ............................................................

  acts_as :prompt
  has_many :test_cases, inverse_of: :coding_prompt, dependent: :destroy


  #~ Validation ...............................................................

  validates :wrapper_code, presence: true
  validates :test_script, presence: true

  accepts_nested_attributes_for :test_cases, allow_destroy: true


  #~ Hooks ....................................................................

  before_validation :set_defaults
  after_save :parse_tests, if: :test_script_changed?


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def question_type
    Exercise::Q_CODING
  end


  # -------------------------------------------------------------
  def is_mcq?
    false
  end


  # -------------------------------------------------------------
  def is_coding?
    true
  end


  # -------------------------------------------------------------
  def language
    exercise_version.exercise.language || 'Java'
  end


  # -------------------------------------------------------------
  def examples
    test_cases.only_examples
  end


  # -------------------------------------------------------------
  def new_answer(args)
    CodingPromptAnswer.new()
  end


  # -------------------------------------------------------------
  def test_file_name
    prompt_dir + '/' + self.class_name + 'Test.' +
      Exercise.extension_of(self.language)
  end


  # -------------------------------------------------------------
  def prepare_starter_code
    result = self.starter_code
    if result.nil?
      result = ''
    end
    return result.gsub(/\b___\b/, '')
  end

  def reparse
    parse_tests
  end

  #~ Private instance methods .................................................
  private

  # -------------------------------------------------------------
  def set_defaults
    # Should the default class name be the same across all languages?
    case self.language
    when 'Java'
      self.class_name ||= 'Answer'
      self.wrapper_code ||= "public class Answer\n{\n    ___\n}\n"
      # TODO: auto-guess method name from starter code
    end
  end


  # -------------------------------------------------------------
  def prompt_dir
    'usr/resources/' + self.language + '/tests/' + self.id.to_s
  end


  # -------------------------------------------------------------
  def parse_tests
    if self.id && !self.test_script.blank?
      # If there are old test cases, clear them out first
      if !self.test_cases.empty?
        self.test_cases.each do |tc|
          tc.delete
        end
        self.test_cases = []
      end

      # Prep the directory to contain the generated test class
      dir = prompt_dir
      if Dir.exist?(dir)
        FileUtils.remove_dir(dir)
      end
      FileUtils.mkdir_p(dir)
      case self.language
      when 'Java'
        if self.test_script =~ /\s*(import[^,;"']*;|public\s+class)/
          parse_JUnit_tests
          return
        end
      end
      # Default, if none of above cases return
      parse_CSV_tests(self.test_script)
      generate_CSV_tests(test_file_name)
    end
  end


  # -------------------------------------------------------------
  def parse_CSV_tests(csv_text)
    # Now parse the test description into test case objects
    CSV.parse(csv_text) do |row|
      tc = TestCase.new(
        weight: 1.0,
        coding_prompt: self,
        input: row[0],
        expected_output: row[1],
        example: false,
        hidden: false,
        static: false,
        screening: false)
      if !row[2].blank?
        tc.parse_description_specifier(row[2])
      end
      if !row[3].blank?
        tc.negative_feedback = row[3]
      end
      if !row[4].blank?
        if row[4] =~ /screening/i
          tc.weight = 1.0
          tc.screening = true
        else
          wt = row[4]
          if wt.sub!(/^screening:\s*/i, '')
            tc.screening = true
          end
          tc.weight = wt.to_f
          if tc.weight < 0
            tc.weight = 1.0
          end
        end
      end
      if tc.save
        self.test_cases << tc
      else
        puts "error saving test case: #{tc.errors.full_messages.to_s}"
      end
    end
  end


  # -------------------------------------------------------------
  def generate_CSV_tests(file_name)
    lang = self.language
    tests = ''
    self.test_cases.only_dynamic.each do |test_case|
      tests << test_case.to_code(lang)
    end
    body = File.read('usr/resources/' + lang + '/' + lang +
      'BaseTestFile.' + Exercise.extension_of(lang))
    File.write(file_name, body % {
      tests: tests,
      method_name: self.method_name,
      class_name: self.class_name
      })
  end


  # -------------------------------------------------------------
  def parse_JUnit_tests
    junit = self.test_script.gsub(/\r\n/, "\n")

    # First, collect any embedded static tests
    junit.scan(
      /(?:\/\/\p{Blank}*static\p{Blank}*tests\p{Blank}*:\p{Blank}*(.*\n(?:\p{Blank}*\/\/.*\n)*))|(?:\/\*\s*static\s*tests\s*:\s*((?:[^*]|(?:\*+[^*\/]))*)\*+\/)/i
      ) do |tests1, tests2|
      if tests2.blank?
        tests = tests1.gsub(/^\p{Blank}*\/\/\p{Blank}*/, '').gsub(/\p{Blank}*$/, '')
      else
        tests = tests2.gsub(/^\p{Blank}*(\*\p{Blank}*)?/, '').gsub(/\p{Blank}*$/, '')
      end
      tests.sub!(/\n*$/m, "\n")
      parse_CSV_tests(tests)
    end

    # Now, extract metadata about and rename each test method
    junit.gsub!(
      /((?:\p{Blank}*\/\/.*\n)|(?:\p{Blank}*\/\*(?:[^*]|(?:\*+[^*\/]))*\*+\/\p{Blank}*\n?))*((?:\s*@(?:Test|Example|Hidden|Screening|(?:Weight|ScoringWeight)\s*\(\s*[0-9]+(?:\.[0-9]*)?\s*\)|(?:Description|Hint|NegativeFeedback)\s*\(\s*"\s*(?:[^"]|\\")*\s*"\s*\)))*)(\s*public\s+void\s+)([a-zA-Z0-9_]+)(\s*\(\s*\))/
      ) do |match|
      comment = Regexp.last_match(1)
      attrs = Regexp.last_match(2)
      publicvoid = Regexp.last_match(3)
      name = Regexp.last_match(4)
      args = Regexp.last_match(5)

      if name =~ /^test/ || attrs =~ /@Test\b/
        tc = TestCase.new(
          weight: 1.0,
          coding_prompt: self,
          input: '',
          expected_output: '',
          example: false,
          hidden: false,
          static: false,
          screening: false)

        tc.description = '<No Test Description Provided!>'
        desc = nil
        # Attempt to pull description string from comments
        if comment =~ /description\s*:\s*((?:[^*\r\n]|(?:\*+[^*\/\r\n]))*)(?:\*\/\s*)?$/i
          desc = $1
        end
        # Attempt to pull description string from attribute, which overrides
        if attrs =~ /@(?:Description|Hint)\s*\(\s*"\s*((?:[^"]|\\")*)\s*"\s*\)/
          desc = $1.gsub(/\\"/, '"')
        end
        # If no description, try to pull it from the method name
        if desc.blank? && name =~ /^(?:test)?(.*)(?:_*[0-9]+)?$/
          namedesc = $1
          if !namedesc.blank?
            namedesc = namedesc.sub(/^_+/, '').sub(/_+$/, '')
            if !namedesc.blank?
              if namedesc =~ /^((?:(?:example|screening|hidden)_)+)([^_].*)$/
                prefix = $1
                suffix = $2
              else
                prefix = ''
                suffix = namedesc
              end
              if suffix.blank?
                if !prefix.blank?
                  desc = prefix
                end
              else
                desc = prefix.gsub(/_/, ':') + suffix.underscore.split(/_+/).join(' ').capitalize
              end
            end
          end
        end
        tc.parse_description_specifier(desc)

        # look for "example" tag in comments or attribute
        if comment =~ /example\s*:\s*true\s*(?:\*\/\s*)?$/i || attrs =~ /@Example\b/
          tc.example = true
        end
        # look for "hidden" tag in comments or attribute
        if comment =~ /hidden\s*:\s*true\s*(?:\*\/\s*)?$/i || attrs =~ /@Hidden\b/
          tc.hidden = true
        end
        # look for "screening" tag in comments or attribute
        if comment =~ /screening\s*:\s*true\s*(?:\*\/\s*)?$/i || attrs =~ /@Screening\b/
          tc.screening = true
        end

        # Attempt to pull negative feedback string from comments
        nfb = nil
        if comment =~ /negative\s*feedback\s*:\s*((?:[^*\r\n]|(?:\*+[^*\/\r\n]))*)(?:\*\/\s*)?$/i
          nfb = $1
        end
        # Attempt to pull negative feedback string from attributes
        if attrs =~ /@NegativeFeedback\s*\(\s*"\s*((?:[^"]|\\")*)\s*"\s*\)/
          nfb = $1.gsub(/\\"/, '"')
        end
        tc.parse_negative_feedback_specifier(nfb)

        # Attempt to pull test case weight from comments
        if comment =~ /(?:scoring\s*)?weight\s*:\s*([0-9]+(?:\.[0-9]*)?)\s*(?:\*\/\s*)?$/i
          tc.weight = $1.to_f
        end
        # Attempt to pull test case weight from attributes
        if attrs =~ /@(?:Scoring)?Weight\s*\(\s*([0-9]+(?:\.[0-9]*)?)\s*\)/
          tc.weight = $1.to_f
        end

        if tc.save
          self.test_cases << tc
          # Rename test method to include TestCase id
          name = "#{name}_#{tc.id}"
        else
          puts "error saving test case: #{tc.errors.full_messages.to_s}"
        end
      end

      rewrite = "#{comment}#{attrs}#{publicvoid}#{name}#{args}"
      # puts "rewritten test decl:\n#{rewrite}\n\n"
      rewrite
    end
    # puts "junit after rewrite:\n#{junit}"
    File.write(test_file_name, junit)
  end

end
