require 'spec_helper'

describe "workouts/index" do
  before(:each) do
    assign(:workouts, [
      stub_model(Workout),
      stub_model(Workout)
    ])
  end

  it "renders a list of workouts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
