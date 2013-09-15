require 'spec_helper'

describe "course_enrollments/new" do
  before(:each) do
    assign(:course_enrollment, stub_model(CourseEnrollment,
      :user => "",
      :course_offering => "",
      :course_role => ""
    ).as_new_record)
  end

  it "renders new course_enrollment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", course_enrollments_path, "post" do
      assert_select "input#course_enrollment_user[name=?]", "course_enrollment[user]"
      assert_select "input#course_enrollment_course_offering[name=?]", "course_enrollment[course_offering]"
      assert_select "input#course_enrollment_course_role[name=?]", "course_enrollment[course_role]"
    end
  end
end
