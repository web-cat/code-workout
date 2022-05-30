class StudentTestCaseResult < ActiveRecord::Base

    # Relationships
    belongs_to :coding_prompt_answer, inverse_of: :student_test_case_results
    belongs_to :student_test_case, class_name: "StudentTestCase", 
        foreign_key: :test_case_id, inverse_of: :student_test_case_result
    
    def display_description
        student_test_case.display_description()
    end

end