require 'spec_helper'

describe TestCase, type: :model do
  describe "#apply_static_check" do
    let(:user) { FactoryBot.build_stubbed(:user) }
    let(:attempt) { double('Attempt', user: user) }
    let(:coding_prompt) { double('CodingPrompt', method_name: 'fibonacci') }
    let(:test_case) do
      TestCase.new(
        input: 'recursion',
        expected_output: 'required',
        static: true,
        screening: true
      )
    end

    let(:mock_tcr) { double('TestCaseResult', save!: true, 'execution_feedback=' => nil) }

    before do
      allow(test_case).to receive(:coding_prompt).and_return(coding_prompt)
      allow(TestCaseResult).to receive(:new).and_return(mock_tcr)
    end

    context "when input is 'recursion'" do
      it "fails an iterative full method submission with an informative message" do
        code = <<~JAVA
          public int fibonacci(int n) {
              int a = 0;
              for (int i = 0; i < n; i++) {
                  a += i;
              }
              return a;
          }
        JAVA

        answer = double('CodingPromptAnswer', attempt: attempt, without_comments: code)
        result = test_case.apply_static_check(answer, code)

        expect(result).to eq("The solution must be recursive: 'fibonacci' is declared, but it is never called recursively.")
      end

      it "passes a recursive full method submission" do
        code = <<~JAVA
          public int fibonacci(int n) {
              if (n <= 1) return n;
              return fibonacci(n - 1) + fibonacci(n - 2);
          }
        JAVA

        answer = double('CodingPromptAnswer', attempt: attempt, without_comments: code)
        result = test_case.apply_static_check(answer, code)

        expect(result).to be_nil
      end

      it "passes a recursive full method submission that uses this.fibonacci()" do
        code = <<~JAVA
          public int fibonacci(int n) {
              if (n <= 1) return n;
              return this.fibonacci(n - 1) + this.fibonacci(n - 2);
          }
        JAVA

        answer = double('CodingPromptAnswer', attempt: attempt, without_comments: code)
        result = test_case.apply_static_check(answer, code)

        expect(result).to be_nil
      end

      it "fails an iterative Python submission" do
        code = <<~PYTHON
          def fibonacci(n):
              a = 0
              for i in range(n):
                  a += i
              return a
        PYTHON

        answer = double('CodingPromptAnswer', attempt: attempt, without_comments: code)
        result = test_case.apply_static_check(answer, code)

        expect(result).to eq("The solution must be recursive: 'fibonacci' is declared, but it is never called recursively.")
      end

      it "passes a recursive Python submission" do
        code = <<~PYTHON
          def fibonacci(n):
            if n <= 1:
                return n
            return fibonacci(n - 1) + fibonacci(n - 2)
        PYTHON

        answer = double('CodingPromptAnswer', attempt: attempt, without_comments: code)
        result = test_case.apply_static_check(answer, code)

        expect(result).to be_nil
      end

      it "fails an iterative body-only submission with the general recursive message" do
        code = <<~JAVA
          int a = 0;
          for (int i = 0; i < n; i++) {
              a += i;
          }
          return a;
        JAVA

        answer = double('CodingPromptAnswer', attempt: attempt, without_comments: code)
        result = test_case.apply_static_check(answer, code)

        expect(result).to eq("The solution must be recursive (method 'fibonacci' must call itself).")
      end

      it "passes a recursive body-only submission" do
        code = <<~JAVA
          if (n <= 1) return n;
          return fibonacci(n - 1) + fibonacci(n - 2);
        JAVA

        answer = double('CodingPromptAnswer', attempt: attempt, without_comments: code)
        result = test_case.apply_static_check(answer, code)

        expect(result).to be_nil
      end

      it "preserves custom negative feedback if provided by the instructor" do
        test_case.negative_feedback = "You must solve this using recursion!"
        code = <<~JAVA
          public int fibonacci(int n) {
              return 0;
          }
        JAVA

        answer = double('CodingPromptAnswer', attempt: attempt, without_comments: code)
        result = test_case.apply_static_check(answer, code)

        expect(result).to eq("You must solve this using recursion!")
      end

      it "supports specifying a helper method via recursion:helperName" do
        test_case.input = 'recursion:fibHelper'
        iterative_code = <<~JAVA
          public int fibonacci(int n) {
              return fibHelper(n, 0, 1);
          }
          private int fibHelper(int n, int a, int b) {
              return a + b;
          }
        JAVA

        answer = double('CodingPromptAnswer', attempt: attempt, without_comments: iterative_code)
        result = test_case.apply_static_check(answer, iterative_code)
        expect(result).to eq("The solution must be recursive: 'fibHelper' is declared, but it is never called recursively.")

        recursive_code = <<~JAVA
          public int fibonacci(int n) {
              return fibHelper(n, 0, 1);
          }
          private int fibHelper(int n, int a, int b) {
              if (n == 0) return a;
              return fibHelper(n - 1, b, a + b);
          }
        JAVA

        answer2 = double('CodingPromptAnswer', attempt: attempt, without_comments: recursive_code)
        result2 = test_case.apply_static_check(answer2, recursive_code)
        expect(result2).to be_nil
      end
    end

    context "other static checks and bug fixes" do
      it "prohibits loops when loops,prohibited is specified" do
        test_case.input = 'loops'
        test_case.expected_output = 'prohibited'

        code = "for (int i = 0; i < 10; i++) {}"
        answer = double('CodingPromptAnswer', attempt: attempt, without_comments: code)
        result = test_case.apply_static_check(answer, code)

        expect(result).to include("Answer cannot use loops")
      end

      it "formats required min count messages without TypeError when required_min_count > 1" do
        test_case.input = 'keywords:if'
        test_case.expected_output = '2'

        code = "int x = 1;"
        answer = double('CodingPromptAnswer', attempt: attempt, without_comments: code)
        result = test_case.apply_static_check(answer, code)

        expect(result).to eq("Answer must use keywords:if at least 2 times")
      end

      it "formats required max count messages without TypeError when required_max_count > 0" do
        test_case.input = 'keywords:if'
        test_case.expected_output = '{,1}'

        code = "if (a) {} if (b) {}"
        answer = double('CodingPromptAnswer', attempt: attempt, without_comments: code)
        result = test_case.apply_static_check(answer, code)

        expect(result).to include("Answer cannot use keywords:if more than 1 time")
      end
    end
  end
end

