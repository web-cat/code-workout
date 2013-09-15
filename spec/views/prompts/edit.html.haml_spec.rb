require 'spec_helper'

describe "prompts/edit" do
  before(:each) do
    @prompt = assign(:prompt, stub_model(Prompt,
      :instruction => "MyText",
      :order => 1,
      :attempts => 1,
      :language => "MyString",
      :max_attempts => 1,
      :feedback => "MyText",
      :difficulty => 1.5,
      :discrimination => 1.5
    ))
  end

  it "renders the edit prompt form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", prompt_path(@prompt), "post" do
      assert_select "textarea#prompt_instruction[name=?]", "prompt[instruction]"
      assert_select "input#prompt_order[name=?]", "prompt[order]"
      assert_select "input#prompt_attempts[name=?]", "prompt[attempts]"
      assert_select "input#prompt_language[name=?]", "prompt[language]"
      assert_select "input#prompt_max_attempts[name=?]", "prompt[max_attempts]"
      assert_select "textarea#prompt_feedback[name=?]", "prompt[feedback]"
      assert_select "input#prompt_difficulty[name=?]", "prompt[difficulty]"
      assert_select "input#prompt_discrimination[name=?]", "prompt[discrimination]"
    end
  end
end
