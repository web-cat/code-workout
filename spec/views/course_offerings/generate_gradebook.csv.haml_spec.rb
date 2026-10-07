require 'spec_helper'

describe "course_offerings/generate_gradebook.csv.haml" do
  let(:workout1) { double('Workout', id: 42, name: 'Variables and Types') }
  let(:workout2) { double('Workout', id: 107, name: 'Loops and Conditionals') }
  let(:course_offering) { double('CourseOffering', workouts: [workout1, workout2], workout_offerings: []) }

  before(:each) do
    assign(:course_offering, course_offering)
    assign(:course_enrolled, [])
  end

  it "renders workout headers with workout name and workout id in parentheses" do
    render
    lines = CSV.parse(rendered)
    header = lines[0]
    expect(header).to eq([
      'E-mail',
      'First Name',
      'Surname',
      'Variables and Types (42)',
      'Loops and Conditionals (107)',
      'Total'
    ])
  end
end
