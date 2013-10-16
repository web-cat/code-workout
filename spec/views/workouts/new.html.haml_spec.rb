require 'spec_helper'

describe "workouts/new" do
  before(:each) do
    assign(:workout, stub_model(Workout).as_new_record)
  end

  it "renders new workout form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", workouts_path, "post" do
    end
  end
end
