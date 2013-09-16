require 'spec_helper'

describe "course_enrollments/show" do
  before(:each) do
    @course_enrollment = assign(:course_enrollment, stub_model(CourseEnrollment,
      :user => "",
      :course_offering => "",
      :course_role => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
  end
end
