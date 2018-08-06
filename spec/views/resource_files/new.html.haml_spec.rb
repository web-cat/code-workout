require 'spec_helper'

describe "resource_files/new" do
  before(:each) do
    assign(:resource_file, stub_model(ResourceFile).as_new_record)
  end

  it "renders new resource_file form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", resource_files_path, "post" do
    end
  end
end
