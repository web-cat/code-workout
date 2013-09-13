require 'spec_helper'

describe "terms/new" do
  before(:each) do
    assign(:term, stub_model(Term,
      :season => 1,
      :year => 1
    ).as_new_record)
  end

  it "renders new term form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", terms_path, "post" do
      assert_select "input#term_season[name=?]", "term[season]"
      assert_select "input#term_year[name=?]", "term[year]"
    end
  end
end
