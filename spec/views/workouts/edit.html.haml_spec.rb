require 'spec_helper'

describe "workouts/edit" do
  before(:each) do
    @workout = assign(:workout, stub_model(Workout))
  end

  it "renders the edit workout form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", workout_path(@workout), "post" do
    end
  end
end
