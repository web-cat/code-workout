require 'spec_helper'

describe "exercises/show" do
  before(:each) do
    @exercise = assign(:exercise, stub_model(Exercise,
      :title => "Title",
      :preamble => "Preamble",
      :user => 1,
      :is_public => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/Preamble/)
    rendered.should match(/1/)
    rendered.should match(/false/)
  end
end
