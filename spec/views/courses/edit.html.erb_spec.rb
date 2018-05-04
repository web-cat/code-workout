require 'spec_helper'

describe "courses/edit" do
  before(:each) do
    @course = assign(:course, stub_model(Course,
      :name => "MyString",
      :number => "MyString",
      :organization_id => 1,
      :url_part => "MyString"
    ))
  end

  it "renders the edit course form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", course_path(@course), "post" do
      assert_select "input#course_name[name=?]", "course[name]"
      assert_select "input#course_number[name=?]", "course[number]"
      assert_select "input#course_organization_id[name=?]", "course[organization_id]"
      assert_select "input#course_url_part[name=?]", "course[url_part]"
    end
  end
end
