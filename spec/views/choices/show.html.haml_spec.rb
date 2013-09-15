require 'spec_helper'

describe "choices/show" do
  before(:each) do
    @choice = assign(:choice, stub_model(Choice,
      :prompt => nil,
      :answer => "Answer",
      :order => 1,
      :feedback => "MyText",
      :value => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(/Answer/)
    rendered.should match(/1/)
    rendered.should match(/MyText/)
    rendered.should match(/1.5/)
  end
end
