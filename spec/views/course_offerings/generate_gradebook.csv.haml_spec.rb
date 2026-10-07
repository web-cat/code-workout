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

  it "includes lti_assignment_id in parentheses when present on the workout offering" do
    workout_offering1 = double('WorkoutOffering', workout: workout1, workout_id: 42, lti_assignment_id: 'lti_abc_123')
    workout_offering2 = double('WorkoutOffering', workout: workout2, workout_id: 107, lti_assignment_id: nil)
    allow(course_offering).to receive(:workout_offerings).and_return([workout_offering1, workout_offering2])

    render
    lines = CSV.parse(rendered)
    header = lines[0]
    expect(header).to eq([
      'E-mail',
      'First Name',
      'Surname',
      'Variables and Types (42, lti_abc_123)',
      'Loops and Conditionals (107)',
      'Total'
    ])
  end
end
