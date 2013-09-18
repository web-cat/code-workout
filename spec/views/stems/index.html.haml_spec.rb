require 'spec_helper'

describe "stems/index" do
  before(:each) do
    assign(:stems, [
      stub_model(Stem,
        :preamble => "MyText"
      ),
      stub_model(Stem,
        :preamble => "MyText"
      )
    ])
  end

  it "renders a list of stems" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
