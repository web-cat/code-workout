require 'spec_helper'

describe "courses/show" do
  before(:each) do
    @course = assign(:course, stub_model(Course,
      :name => "Name",
      :number => "Number",
      :organization_id => 1,
      :url_part => "Url Part"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Number/)
    rendered.should match(/1/)
    rendered.should match(/Url Part/)
  end
end
