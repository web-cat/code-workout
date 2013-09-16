require 'spec_helper'

describe "course_roles/show" do
  before(:each) do
    @course_role = assign(:course_role, stub_model(CourseRole,
      :name => "Name",
      :can_manage_course => false,
      :can_manage_assignments => false,
      :can_grade_submissions => false,
      :can_view_other_submissions => false,
      :builtin => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/false/)
    rendered.should match(/false/)
    rendered.should match(/false/)
    rendered.should match(/false/)
    rendered.should match(/false/)
  end
end
