require 'spec_helper'

describe "resource_files/index" do
  before(:each) do
    assign(:resource_files, [
      stub_model(ResourceFile),
      stub_model(ResourceFile)
    ])
  end

  it "renders a list of resource_files" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
