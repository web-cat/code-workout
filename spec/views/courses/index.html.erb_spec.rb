require 'spec_helper'

describe "courses/index" do
  before(:each) do
    assign(:courses, [
      stub_model(Course,
        :name => "Name",
        :number => "Number",
        :organization_id => 1,
        :url_part => "Url Part"
      ),
      stub_model(Course,
        :name => "Name",
        :number => "Number",
        :organization_id => 1,
        :url_part => "Url Part"
      )
    ])
  end

  it "renders a list of courses" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Number".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Url Part".to_s, :count => 2
  end
end
