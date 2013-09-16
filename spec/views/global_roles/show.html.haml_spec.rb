require 'spec_helper'

describe "global_roles/show" do
  before(:each) do
    @global_role = assign(:global_role, stub_model(GlobalRole,
      :name => "Name",
      :can_manage_all_courses => false,
      :can_edit_system_configuration => false,
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
  end
end
