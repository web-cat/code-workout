require 'spec_helper'

describe "organizations/show" do
  before(:each) do
    @organization = assign(:organization, stub_model(Organization,
      :display_name => "Display Name",
      :url_part => "Url Part"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Display Name/)
    rendered.should match(/Url Part/)
  end
end
