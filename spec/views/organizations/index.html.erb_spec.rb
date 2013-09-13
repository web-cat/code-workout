require 'spec_helper'

describe "organizations/index" do
  before(:each) do
    assign(:organizations, [
      stub_model(Organization,
        :display_name => "Display Name",
        :url_part => "Url Part"
      ),
      stub_model(Organization,
        :display_name => "Display Name",
        :url_part => "Url Part"
      )
    ])
  end

  it "renders a list of organizations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Display Name".to_s, :count => 2
    assert_select "tr>td", :text => "Url Part".to_s, :count => 2
  end
end
