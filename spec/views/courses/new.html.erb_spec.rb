require 'spec_helper'

describe "courses/new" do
  before(:each) do
    assign(:course, stub_model(Course,
      :name => "MyString",
      :number => "MyString",
      :organization_id => 1,
      :url_part => "MyString"
    ).as_new_record)
  end

  it "renders new course form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", courses_path, "post" do
      assert_select "input#course_name[name=?]", "course[name]"
      assert_select "input#course_number[name=?]", "course[number]"
      assert_select "input#course_organization_id[name=?]", "course[organization_id]"
      assert_select "input#course_url_part[name=?]", "course[url_part]"
    end
  end
end
