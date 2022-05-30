module TestCaseHelper

    # if called from coding_prompt.rb, cp_answer is nil
    def generate_CSV_tests(file_name, coding_prompt, cp_answer = nil)
        lang = coding_prompt.language
        tests = ''
        if cp_answer.nil?
            loc = coding_prompt.test_cases.only_dynamic
        else
            loc = cp_answer.student_test_cases
        end
        loc.each do |test_case|
            tests << self.to_code(lang, test_case)
        end
        body = File.read('usr/resources/' + lang + '/' + lang +
          'BaseTestFile.' + Exercise.extension_of(lang))
        File.write(file_name, body % {
          tests: tests,
          method_name: coding_prompt.method_name,
          class_name: coding_prompt.class_name
          })
      end
    
    # moved from test_case.rb and student_test_case.rb
    def to_code(language, test_case)
        inp = test_case.input
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
        if test_case.is_a?(StudentTestCase)
            coding_prompt = test_case.coding_prompt_answer.actable.prompt.specific
            TEST_METHOD_TEMPLATES[language] % {
                id: test_case.id.to_s,
                method_name: coding_prompt.method_name,
                class_name: coding_prompt.class_name,
                input: inp,
                expected_output: test_case.expected_output,
                negative_feedback: 'check your understanding',
              }
        else
            TEST_METHOD_TEMPLATES[language] % {
                id: test_case.id.to_s,
                method_name: test_case.coding_prompt.method_name,
                class_name: test_case.coding_prompt.class_name,
                input: inp,
                expected_output: test_case.expected_output,
                negative_feedback: test_case.negative_feedback,
                array: ((test_case.expected_output.start_with?('new ') &&
                  test_case.expected_output.include?('[]')) ||
                  test_case.expected_output.start_with?('array(')) ? 'Array' : ''
              }
        end
    end


      # heredoc
      # moved from test_case.rb and student_test_case.rb
      TEST_METHOD_TEMPLATES = {
        'Ruby' => <<RUBY_TEST,
    def test%{id}
      assert_equal(%{expected_output}, @@subject.%{method_name}(%{input}), "%{negative_feedback}")
    end
  
RUBY_TEST
        'Python' => <<PYTHON_TEST,
      def test%{id}(self):
          self.assertEqual(%{expected_output}, self.__%{method_name}(%{input}))
  
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
