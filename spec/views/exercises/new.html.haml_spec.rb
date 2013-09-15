require 'spec_helper'

describe "exercises/new" do
  before(:each) do
    assign(:exercise, stub_model(Exercise,
      :title => "MyString",
      :preamble => "MyString",
      :user => 1,
      :is_public => false
    ).as_new_record)
  end

  it "renders new exercise form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", exercises_path, "post" do
      assert_select "input#exercise_title[name=?]", "exercise[title]"
      assert_select "input#exercise_preamble[name=?]", "exercise[preamble]"
      assert_select "input#exercise_user[name=?]", "exercise[user]"
      assert_select "input#exercise_is_public[name=?]", "exercise[is_public]"
    end
  end
end
