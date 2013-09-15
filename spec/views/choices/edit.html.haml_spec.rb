require 'spec_helper'

describe "choices/edit" do
  before(:each) do
    @choice = assign(:choice, stub_model(Choice,
      :prompt => nil,
      :answer => "MyString",
      :order => 1,
      :feedback => "MyText",
      :value => 1.5
    ))
  end

  it "renders the edit choice form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", choice_path(@choice), "post" do
      assert_select "input#choice_prompt[name=?]", "choice[prompt]"
      assert_select "input#choice_answer[name=?]", "choice[answer]"
      assert_select "input#choice_order[name=?]", "choice[order]"
      assert_select "textarea#choice_feedback[name=?]", "choice[feedback]"
      assert_select "input#choice_value[name=?]", "choice[value]"
    end
  end
end
