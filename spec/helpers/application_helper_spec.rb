require 'spec_helper'

describe ApplicationHelper, type: :helper do
  describe "#embedded_lti_launch?" do
    it "returns false when lti_launch is not present" do
      expect(helper.embedded_lti_launch?).to be_falsey
    end

    it "returns true when lti_launch is present and document_target is iframe" do
      controller.params[:lti_launch] = 'true'
      controller.params[:launch_presentation_document_target] = 'iframe'
      expect(helper.embedded_lti_launch?).to be true
    end

    it "returns true by default when lti_launch is present and document_target is not specified" do
      controller.params[:lti_launch] = 'true'
      expect(helper.embedded_lti_launch?).to be true
    end

    it "returns false when lti_launch is present and document_target is window (loaded in a new tab)" do
      controller.params[:lti_launch] = 'true'
      controller.params[:launch_presentation_document_target] = 'window'
      expect(helper.embedded_lti_launch?).to be false
    end

    it "checks session[:lti_document_target] as a fallback" do
      controller.params[:lti_launch] = 'true'
      session[:lti_document_target] = 'window'
      expect(helper.embedded_lti_launch?).to be false
    end
  end

  describe "#choice_letter" do
    it "returns the letter corresponding to the position in the prompt's choices" do
      choice1 = double('Choice', id: 10, position: 1)
      choice2 = double('Choice', id: 20, position: 2)
      prompt = double('MultipleChoicePrompt', choices: [choice1, choice2])
      allow(choice1).to receive(:multiple_choice_prompt).and_return(prompt)
      allow(choice2).to receive(:multiple_choice_prompt).and_return(prompt)

      expect(helper.choice_letter(choice1)).to eq('A')
      expect(helper.choice_letter(choice2)).to eq('B')
    end

    it "falls back to 1-based position when prompt is not available" do
      choice = double('Choice', multiple_choice_prompt: nil, position: 3)
      expect(helper.choice_letter(choice)).to eq('C')
    end

    it "falls back to choice answer or string when position is not set" do
      choice = double('Choice', multiple_choice_prompt: nil, position: nil, answer: 'Option 1')
      expect(helper.choice_letter(choice)).to eq('Option 1')
    end
  end

  describe "#mc_answer_display" do
    it "formats single choice as 'choice: A'" do
      choice = double('Choice', id: 1, multiple_choice_prompt: nil, position: 1)
      answer = double('MultipleChoicePromptAnswer', prompt: nil, choices: [choice])
      expect(helper.mc_answer_display(answer)).to eq('choice: A')
    end

    it "formats multiple choices separated by commas" do
      choice1 = double('Choice', id: 1, multiple_choice_prompt: nil, position: 1)
      choice2 = double('Choice', id: 3, multiple_choice_prompt: nil, position: 3)
      answer = double('MultipleChoicePromptAnswer', prompt: nil, choices: [choice1, choice2])
      expect(helper.mc_answer_display(answer)).to eq('choice: A, C')
    end

    it "handles actable prompt answer wrapper with .specific" do
      choice = double('Choice', id: 2, multiple_choice_prompt: nil, position: 2)
      specific = double('MultipleChoicePromptAnswer', choices: [choice])
      answer = double('PromptAnswer', prompt: nil, specific: specific)
      expect(helper.mc_answer_display(answer)).to eq('choice: B')
    end

    it "returns 'choice: (none)' when no choices were selected" do
      answer = double('MultipleChoicePromptAnswer', prompt: nil, choices: [])
      expect(helper.mc_answer_display(answer)).to eq('choice: (none)')
    end
  end
end

