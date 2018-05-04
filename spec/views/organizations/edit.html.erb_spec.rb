require 'spec_helper'

describe "organizations/edit" do
  before(:each) do
    @organization = assign(:organization, stub_model(Organization,
      :display_name => "MyString",
      :url_part => "MyString"
    ))
  end

  it "renders the edit organization form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", organization_path(@organization), "post" do
      assert_select "input#organization_display_name[name=?]", "organization[display_name]"
      assert_select "input#organization_url_part[name=?]", "organization[url_part]"
    end
  end
end
