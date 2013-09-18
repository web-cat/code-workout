require 'spec_helper'

describe "stems/show" do
  before(:each) do
    @stem = assign(:stem, stub_model(Stem,
      :preamble => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
  end
end
