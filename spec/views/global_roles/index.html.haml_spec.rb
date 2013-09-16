require 'spec_helper'

describe "global_roles/index" do
  before(:each) do
    assign(:global_roles, [
      stub_model(GlobalRole,
        :name => "Name",
        :can_manage_all_courses => false,
        :can_edit_system_configuration => false,
        :builtin => false
      ),
      stub_model(GlobalRole,
        :name => "Name",
        :can_manage_all_courses => false,
        :can_edit_system_configuration => false,
        :builtin => false
      )
    ])
  end

  it "renders a list of global_roles" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
