require 'spec_helper'

describe "course_offerings/show" do
  before(:each) do
    @course_offering = assign(:course_offering, stub_model(CourseOffering,
      :course_id => 1,
      :term_id => 2,
      :name => "Name",
      :label => "Label",
      :url => "Url",
      :organization_id => 3,
      :self_enrollment_allowed => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Name/)
    rendered.should match(/Label/)
    rendered.should match(/Url/)
    rendered.should match(/3/)
    rendered.should match(/false/)
  end
end
