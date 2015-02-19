module ExercisesHelper

  def generate_tests(exid, language, class_name, method_name)
      tests = ''
      exercise = Exercise.find(exid)
      exercise.coding_question.test_cases.each_with_index do |test_case, i|
      i += 1
      if language == 'Ruby'
        tests = <<RUBY_TEST

  def test#{class_name}#{i}
    if #{method_name}(#{test_case.input.gsub(';', ',')}) ==
      #{test_case.expected_output}
      @@f.write("1,,#{i}\n")
    else
      @@f.write("0,\"#{test_case.negative_feedback.chomp}\",#{i}\n")
    end
    assert_equal(#{method_name}(#{test_case.input.gsub(';', ',')}),
      #{test_case.expected_output})
  end

RUBY_TEST

      elsif language == 'Python'
        tests = <<PYTHON_TEST

    def test#{i}(self):
        if #{class_name}.#{method_name}(#{test_case.input.gsub(';', ',')}) == #{test_case.expected_output}:
            #{class_name}Test.f.write("1,,#{i}\n")
        else:
            #{class_name}Test.f.write("0,\"#{test_case.negative_feedback.chomp}\",#{i.to_s}\n")
        self.assertEqual(#{class_name}.#{method_name}(#{test_case.input.gsub(';', ',')}),#{test_case.expected_output})

PYTHON_TEST

      elsif language == 'Java'
        tests = <<JAVA_TEST
    @Test
    public void test#{method_name}#{i}()
    {
        if (f.#{method_name}(#{test_case.input.gsub(';', ',')}) ==
            #{test_case.expected_output})
        {
            fout.println("1,," + cnt);
        }
        else
        {
            fout.println("0,\"#{test_case.negative_feedback.chomp}\"," + cnt);
        }
        assertEquals(f.#{method_name}(#{test_case.input.gsub(';', ',')}),
            #{test_case.expected_output});
    }

JAVA_TEST

      end

    end
    return tests
  end

end
