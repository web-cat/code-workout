require 'spec_helper'

describe "workouts/show" do
  before(:each) do
    @workout = assign(:workout, stub_model(Workout))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
