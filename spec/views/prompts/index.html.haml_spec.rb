require 'spec_helper'

describe "prompts/index" do
  before(:each) do
    assign(:prompts, [
      stub_model(Prompt,
        :instruction => "MyText",
        :order => 1,
        :attempts => 2,
        :language => "Language",
        :max_attempts => 3,
        :feedback => "MyText",
        :difficulty => 1.5,
        :discrimination => 1.5
      ),
      stub_model(Prompt,
        :instruction => "MyText",
        :order => 1,
        :attempts => 2,
        :language => "Language",
        :max_attempts => 3,
        :feedback => "MyText",
        :difficulty => 1.5,
        :discrimination => 1.5
      )
    ])
  end

  it "renders a list of prompts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Language".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
  end
end
