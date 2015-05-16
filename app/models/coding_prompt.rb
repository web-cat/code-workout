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


  # -------------------------------------------------------------
  def new_answer(args)
    CodingPromptAnswer.new()
  end


  #~ Private instance methods .................................................
  private

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
      dir = 'usr/resources/Java/tests/' + self.id.to_s
      if Dir.exist?(dir)
        FileUtils.remove_dir(dir)
      end
      FileUtils.mkdir_p(dir)

      # Now parse the test description into test case objects
      CSV.parse(self.test_script) do |row|
        tc = TestCase.new(
          weight: 1.0,
          coding_prompt: self,
          input: row[0],
          expected_output: row[1])
        if !row[2].blank?
          tc.description = row[2]
        else
          tc.description = self.method_name + '(' + tc.input +
            ') -> ' + tc.expected_output
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

end
