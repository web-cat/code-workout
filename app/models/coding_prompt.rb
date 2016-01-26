# == Schema Information
#
# Table name: coding_prompts
#
#  id           :integer          not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  class_name   :string(255)
#  wrapper_code :text             not null
#  test_script  :text             not null
#  method_name  :string(255)
#  starter_code :text
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

  after_save :parse_tests


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

  def examples
    test_cases.select{ |tc| tc.is_example? }
  end

  # -------------------------------------------------------------
  def new_answer(args)
    CodingPromptAnswer.new()
  end


  # -------------------------------------------------------------
  def test_file_name
    dir = prompt_dir
    if !Dir.exist?(dir)
      FileUtils.mkdir_p(dir)
    end
    file_name = dir + '/' + self.class_name + 'Test.' +
      Exercise.extension_of(exercise_version.exercise.language)
    if !File.exist?(file_name)
      generate_tests(file_name)
    end
    return file_name
  end


  # -------------------------------------------------------------
  def prepare_starter_code
    result = self.starter_code
    if result.nil?
      result = ''
    end
    return result.gsub(/\b___\b/, '')
  end

  #~ Private instance methods .................................................
  private

  # -------------------------------------------------------------
  def prompt_dir
    'usr/resources/Java/tests/' + self.id.to_s
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

      # Now parse the test description into test case objects
      CSV.parse(self.test_script) do |row|
        tc = TestCase.new(
          weight: 1.0,
          coding_prompt: self,
          input: row[0],
          expected_output: row[1])
        if tc.input && tc.input.include?(';')
          tc.input = tc.input.gsub(/;\s*/, ', ')
        end
        if !row[2].blank?
          tc.description = row[2]
        end
        if !row[3].blank?
          tc.negative_feedback = row[3]
        end
        if !row[4].blank?
          tc.weight = row[4].to_f
          if tc.weight < 0
            tc.weight = 1.0
          end
        end
        if tc.save
          self.test_cases << tc
        else
          puts "error saving test case: #{tc.errors.full_messages.to_s}"
        end
      end


       # TODO: Generate the test case class in code form here
    end
  end


  # -------------------------------------------------------------
  def generate_tests(file_name)
    language = exercise_version.exercise.language
    tests = ''
    self.test_cases.each do |test_case|
      tests << test_case.to_code(language)
    end
    body = File.read('usr/resources/' + language + '/' + language +
      'BaseTestFile.' + Exercise.extension_of(language))
    File.write(file_name, body % {
      tests: tests,
      method_name: self.method_name,
      class_name: self.class_name
      })
  end

end
