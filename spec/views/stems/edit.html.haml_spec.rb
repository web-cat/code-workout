require 'spec_helper'

describe "stems/edit" do
  before(:each) do
    @stem = assign(:stem, stub_model(Stem,
      :preamble => "MyText"
    ))
  end

  it "renders the edit stem form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", stem_path(@stem), "post" do
      assert_select "textarea#stem_preamble[name=?]", "stem[preamble]"
    end
  end
end
