require 'spec_helper'

describe "organizations/new" do
  before(:each) do
    assign(:organization, stub_model(Organization,
      :display_name => "MyString",
      :url_part => "MyString"
    ).as_new_record)
  end

  it "renders new organization form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", organizations_path, "post" do
      assert_select "input#organization_display_name[name=?]", "organization[display_name]"
      assert_select "input#organization_url_part[name=?]", "organization[url_part]"
    end
  end
end
