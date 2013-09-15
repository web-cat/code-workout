require 'spec_helper'

describe "choices/new" do
  before(:each) do
    assign(:choice, stub_model(Choice,
      :prompt => nil,
      :answer => "MyString",
      :order => 1,
      :feedback => "MyText",
      :value => 1.5
    ).as_new_record)
  end

  it "renders new choice form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", choices_path, "post" do
      assert_select "input#choice_prompt[name=?]", "choice[prompt]"
      assert_select "input#choice_answer[name=?]", "choice[answer]"
      assert_select "input#choice_order[name=?]", "choice[order]"
      assert_select "textarea#choice_feedback[name=?]", "choice[feedback]"
      assert_select "input#choice_value[name=?]", "choice[value]"
    end
  end
end
