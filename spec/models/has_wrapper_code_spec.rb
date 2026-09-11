require 'spec_helper'

RSpec.describe HasWrapperCode, type: :model do
  self.use_transactional_tests = false

  describe '#wrap_code' do
    it 'preserves indentation on multi-line answers in Python wrapper' do
      prompt = CodingPrompt.new(wrapper_code: "def doSomething():\n  ___\n")
      answer = "x = 1\nif x > 0:\n    return True\nreturn False"
      expected = "def doSomething():\n  x = 1\n  if x > 0:\n      return True\n  return False\n"
      expect(prompt.wrap_code(answer)).to eq(expected)
    end

    it 'handles single-line answers properly' do
      prompt = CodingPrompt.new(wrapper_code: "def doSomething():\n  ___\n")
      expect(prompt.wrap_code("return 42")).to eq("def doSomething():\n  return 42\n")
    end

    it 'handles answers with trailing newline without adding extra spaces' do
      prompt = CodingPrompt.new(wrapper_code: "def doSomething():\n  ___\n")
      expect(prompt.wrap_code("x = 1\ny = 2\n")).to eq("def doSomething():\n  x = 1\n  y = 2\n\n")
    end

    it 'handles Java 4-space class indentation' do
      prompt = CodingPrompt.new(wrapper_code: "public class Answer\n{\n    ___\n}\n")
      answer = "public int foo()\n{\n    return 42;\n}"
      expected = "public class Answer\n{\n    public int foo()\n    {\n        return 42;\n    }\n}\n"
      expect(prompt.wrap_code(answer)).to eq(expected)
    end

    it 'handles wrapper with no indentation' do
      prompt = CodingPrompt.new(wrapper_code: "___\n")
      answer = "def foo():\n    return 1"
      expect(prompt.wrap_code(answer)).to eq("def foo():\n    return 1\n")
    end

    it 'preserves backslashes in student code without regex escape corruption' do
      prompt = CodingPrompt.new(wrapper_code: "def doSomething():\n  ___\n")
      answer = 'x = /\b___\b/ \1 \2 \\'
      wrapped = prompt.wrap_code(answer)
      expect(wrapped).to include('x = /\b___\b/ \1 \2 \\')
    end

    it 'handles answers with Windows CRLF line endings' do
      prompt = CodingPrompt.new(wrapper_code: "def doSomething():\n  ___\n")
      answer = "a = 1\r\nb = 2\r\n"
      expected = "def doSomething():\n  a = 1\r\n  b = 2\r\n\n"
      expect(prompt.wrap_code(answer)).to eq(expected)
    end

    it 'returns answer text if wrapper_code is blank' do
      prompt = CodingPrompt.new(wrapper_code: nil)
      expect(prompt.wrap_code("x = 1")).to eq("x = 1")
    end

    it 'returns wrapper_code if placeholder is missing' do
      prompt = CodingPrompt.new(wrapper_code: "def no_placeholder():\n  pass\n")
      expect(prompt.wrap_code("x = 1")).to eq("def no_placeholder():\n  pass\n")
    end
  end

  describe '#pre_lines' do
    it 'returns line count before placeholder' do
      prompt = CodingPrompt.new(wrapper_code: "public class Answer\n{\n    ___\n}\n")
      expect(prompt.pre_lines).to eq(2)
    end

    it 'returns 1 when placeholder is on second line' do
      prompt = CodingPrompt.new(wrapper_code: "def doSomething():\n  ___\n")
      expect(prompt.pre_lines).to eq(1)
    end

    it 'returns 0 when placeholder is on first line' do
      prompt = CodingPrompt.new(wrapper_code: "___\n")
      expect(prompt.pre_lines).to eq(0)
    end

    it 'returns 0 when wrapper_code is blank or has no placeholder' do
      expect(CodingPrompt.new(wrapper_code: nil).pre_lines).to eq(0)
      expect(CodingPrompt.new(wrapper_code: "no placeholder").pre_lines).to eq(0)
    end
  end

  describe 'ParsonsPrompt inclusion' do
    it 'provides wrap_code and pre_lines to ParsonsPrompt' do
      prompt = ParsonsPrompt.new(wrapper_code: "def doSomething():\n  ___\n")
      expect(prompt.wrap_code("x = 1\ny = 2")).to eq("def doSomething():\n  x = 1\n  y = 2\n")
      expect(prompt.pre_lines).to eq(1)
    end
  end

  describe 'CodingPromptAnswer integration' do
    it 'provides code_body and pre_lines on answer instance' do
      prompt = CodingPrompt.new(wrapper_code: "def doSomething():\n  ___\n")
      answer = CodingPromptAnswer.new(answer: "x = 1\ny = 2")
      allow(answer).to receive(:prompt).and_return(prompt)
      expect(answer.code_body).to eq("def doSomething():\n  x = 1\n  y = 2\n")
      expect(answer.pre_lines).to eq(1)
    end
  end
end
