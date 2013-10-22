require 'spec_helper'

describe "stems/new" do
  before(:each) do
    assign(:stem, stub_model(Stem,
      :preamble => "MyText"
    ).as_new_record)
  end

  it "renders new stem form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", stems_path, "post" do
      assert_select "textarea#stem_preamble[name=?]", "stem[preamble]"
    end
  end
end
