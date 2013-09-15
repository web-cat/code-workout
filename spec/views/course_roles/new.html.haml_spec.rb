require 'spec_helper'

describe "course_roles/new" do
  before(:each) do
    assign(:course_role, stub_model(CourseRole,
      :name => "MyString",
      :can_manage_course => false,
      :can_manage_assignments => false,
      :can_grade_submissions => false,
      :can_view_other_submissions => false,
      :builtin => false
    ).as_new_record)
  end

  it "renders new course_role form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", course_roles_path, "post" do
      assert_select "input#course_role_name[name=?]", "course_role[name]"
      assert_select "input#course_role_can_manage_course[name=?]", "course_role[can_manage_course]"
      assert_select "input#course_role_can_manage_assignments[name=?]", "course_role[can_manage_assignments]"
      assert_select "input#course_role_can_grade_submissions[name=?]", "course_role[can_grade_submissions]"
      assert_select "input#course_role_can_view_other_submissions[name=?]", "course_role[can_view_other_submissions]"
      assert_select "input#course_role_builtin[name=?]", "course_role[builtin]"
    end
  end
end
