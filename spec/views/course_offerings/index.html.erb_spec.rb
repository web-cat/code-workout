require 'spec_helper'

describe "course_offerings/index" do
  before(:each) do
    assign(:course_offerings, [
      stub_model(CourseOffering,
        :course_id => 1,
        :term_id => 2,
        :name => "Name",
        :label => "Label",
        :url => "Url",
        :organization_id => 3,
        :self_enrollment_allowed => false
      ),
      stub_model(CourseOffering,
        :course_id => 1,
        :term_id => 2,
        :name => "Name",
        :label => "Label",
        :url => "Url",
        :organization_id => 3,
        :self_enrollment_allowed => false
      )
    ])
  end

  it "renders a list of course_offerings" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Label".to_s, :count => 2
    assert_select "tr>td", :text => "Url".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
