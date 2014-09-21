require 'spec_helper'

describe "resource_files/edit" do
  before(:each) do
    @resource_file = assign(:resource_file, stub_model(ResourceFile))
  end

  it "renders the edit resource_file form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", resource_file_path(@resource_file), "post" do
    end
  end
end
