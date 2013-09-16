require 'spec_helper'

describe "global_roles/edit" do
  before(:each) do
    @global_role = assign(:global_role, stub_model(GlobalRole,
      :name => "MyString",
      :can_manage_all_courses => false,
      :can_edit_system_configuration => false,
      :builtin => false
    ))
  end

  it "renders the edit global_role form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", global_role_path(@global_role), "post" do
      assert_select "input#global_role_name[name=?]", "global_role[name]"
      assert_select "input#global_role_can_manage_all_courses[name=?]", "global_role[can_manage_all_courses]"
      assert_select "input#global_role_can_edit_system_configuration[name=?]", "global_role[can_edit_system_configuration]"
      assert_select "input#global_role_builtin[name=?]", "global_role[builtin]"
    end
  end
end
