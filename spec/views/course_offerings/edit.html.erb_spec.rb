require 'spec_helper'

describe "course_offerings/edit" do
  before(:each) do
    @course_offering = assign(:course_offering, stub_model(CourseOffering,
      :course_id => 1,
      :term_id => 1,
      :name => "MyString",
      :label => "MyString",
      :url => "MyString",
      :organization_id => 1,
      :self_enrollment_allowed => false
    ))
  end

  it "renders the edit course_offering form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", course_offering_path(@course_offering), "post" do
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
