require 'spec_helper'

describe "course_enrollments/index" do
  before(:each) do
    assign(:course_enrollments, [
      stub_model(CourseEnrollment,
        :user => "",
        :course_offering => "",
        :course_role => ""
      ),
      stub_model(CourseEnrollment,
        :user => "",
        :course_offering => "",
        :course_role => ""
      )
    ])
  end

  it "renders a list of course_enrollments" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
