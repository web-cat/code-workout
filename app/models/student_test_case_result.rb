class StudentTestCaseResult < ActiveRecord::Base

    # Relationships
    belongs_to :coding_prompt_answer
    belongs_to :student_test_case

    def display_description
        student_test_case.display_description(self.pass)
    end

end