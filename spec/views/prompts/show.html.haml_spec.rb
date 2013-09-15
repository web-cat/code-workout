require 'spec_helper'

describe "prompts/show" do
  before(:each) do
    @prompt = assign(:prompt, stub_model(Prompt,
      :instruction => "MyText",
      :order => 1,
      :attempts => 2,
      :language => "Language",
      :max_attempts => 3,
      :feedback => "MyText",
      :difficulty => 1.5,
      :discrimination => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Language/)
    rendered.should match(/3/)
    rendered.should match(/MyText/)
    rendered.should match(/1.5/)
    rendered.should match(/1.5/)
  end
end
