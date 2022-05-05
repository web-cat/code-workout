class StudentTestCase < ActiveRecord::Base

    # Relationships
    belongs_to :coding_prompt_answer
    
    def record_result(answer, test_results_array)
        tcr = StudentTestCaseResult.new(
          test_case_id: self,
          coding_prompt_answer: answer,
          pass: (test_results_array.length == 8 && test_results_array[7].to_i == 1)
          )
          # This logic is somewhat Java-specific, and needs to be refactored
          # to better support other languages.
        if !test_results_array[5].blank?
            exception_name = test_results_array[6] #.sub(/^.*\./, '')
            if !(['AssertionFailedError',
              'AssertionError',
              'ComparisonFailure',
              'ReflectionSupportError'].include?(exception_name) ||
              (exception_name == 'Exception' &&
              test_results_array[6].start_with?('test timed out'))) ||
              test_results_array[6].blank? ||
              "null" == test_results_array[6]
              tcr.feedback = exception_name
              puts(tcr.feedback)
            end
        end
        tcr.save!    
    end

    def display_description(pass = true)
        result = self.feedback
        result
    end

end