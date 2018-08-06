require 'spec_helper'

describe "resource_files/show" do
  before(:each) do
    @resource_file = assign(:resource_file, stub_model(ResourceFile))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
