require 'spec_helper'

describe "courses/generate_gradebook.csv.haml" do
  let(:workout1) { double('Workout', id: 42, name: 'Variables and Types') }
  let(:workout2) { double('Workout', id: 107, name: 'Loops and Conditionals') }
  let(:offering) { double('CourseOffering', id: 1, name: 'Section 1', workouts: [workout1, workout2], workout_offerings: []) }
  let(:course) { double('Course', course_offerings: [offering]) }

  before(:each) do
    assign(:course, course)
    allow(CourseEnrollment).to receive(:where).with(course_offering_id: offering.id).and_return([])
  end

  it "renders workout headers with workout name and workout id in parentheses" do
    render
    lines = CSV.parse(rendered)
    header = lines[0]
    expect(header).to eq([
      'Course Offering Id',
      'Course Offering',
      'First Name',
      'Second Name',
      'Variables and Types (42)',
      'Loops and Conditionals (107)',
      'Total'
    ])
  end

  it "includes lti_assignment_id in parentheses when present on the workout offering" do
    workout_offering1 = double('WorkoutOffering', workout: workout1, workout_id: 42, lti_assignment_id: 'lti_abc_123')
    workout_offering2 = double('WorkoutOffering', workout: workout2, workout_id: 107, lti_assignment_id: nil)
    allow(offering).to receive(:workout_offerings).and_return([workout_offering1, workout_offering2])

    render
    lines = CSV.parse(rendered)
    header = lines[0]
    expect(header).to eq([
      'Course Offering Id',
      'Course Offering',
      'First Name',
      'Second Name',
      'Variables and Types (42, lti_abc_123)',
      'Loops and Conditionals (107)',
      'Total'
    ])
  end
end
