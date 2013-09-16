require 'spec_helper'

describe "course_roles/index" do
  before(:each) do
    assign(:course_roles, [
      stub_model(CourseRole,
        :name => "Name",
        :can_manage_course => false,
        :can_manage_assignments => false,
        :can_grade_submissions => false,
        :can_view_other_submissions => false,
        :builtin => false
      ),
      stub_model(CourseRole,
        :name => "Name",
        :can_manage_course => false,
        :can_manage_assignments => false,
        :can_grade_submissions => false,
        :can_view_other_submissions => false,
        :builtin => false
      )
    ])
  end

  it "renders a list of course_roles" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
