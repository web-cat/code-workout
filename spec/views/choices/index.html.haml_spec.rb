require 'spec_helper'

describe "choices/index" do
  before(:each) do
    assign(:choices, [
      stub_model(Choice,
        :prompt => nil,
        :answer => "Answer",
        :order => 1,
        :feedback => "MyText",
        :value => 1.5
      ),
      stub_model(Choice,
        :prompt => nil,
        :answer => "Answer",
        :order => 1,
        :feedback => "MyText",
        :value => 1.5
      )
    ])
  end

  it "renders a list of choices" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Answer".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
  end
end
