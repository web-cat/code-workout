require 'spec_helper'

describe "course_offerings/new" do
  before(:each) do
    assign(:course_offering, stub_model(CourseOffering,
      :course_id => 1,
      :term_id => 1,
      :name => "MyString",
      :label => "MyString",
      :url => "MyString",
      :organization_id => 1,
      :self_enrollment_allowed => false
    ).as_new_record)
  end

  it "renders new course_offering form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", course_offerings_path, "post" do
      assert_select "input#course_offering_course_id[name=?]", "course_offering[course_id]"
      assert_select "input#course_offering_term_id[name=?]", "course_offering[term_id]"
      assert_select "input#course_offering_name[name=?]", "course_offering[name]"
      assert_select "input#course_offering_label[name=?]", "course_offering[label]"
      assert_select "input#course_offering_url[name=?]", "course_offering[url]"
      assert_select "input#course_offering_organization_id[name=?]", "course_offering[organization_id]"
      assert_select "input#course_offering_self_enrollment_allowed[name=?]", "course_offering[self_enrollment_allowed]"
    end
  end
end
