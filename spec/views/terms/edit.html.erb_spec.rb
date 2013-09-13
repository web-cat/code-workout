require 'spec_helper'

describe "terms/edit" do
  before(:each) do
    @term = assign(:term, stub_model(Term,
      :season => 1,
      :year => 1
    ))
  end

  it "renders the edit term form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", term_path(@term), "post" do
      assert_select "input#term_season[name=?]", "term[season]"
      assert_select "input#term_year[name=?]", "term[year]"
    end
  end
end
