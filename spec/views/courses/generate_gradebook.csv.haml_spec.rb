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
end
