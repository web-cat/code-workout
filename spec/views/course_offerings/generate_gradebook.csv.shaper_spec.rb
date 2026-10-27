require 'spec_helper'

describe "course_offerings/generate_gradebook.csv.shaper" do
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

  it "renders student rows and properly quotes values with commas and quotes without html escaping" do
    student_role = CourseRole.find_by(name: 'Student') || double('CourseRole', id: 3)
    allow(CourseRole).to receive(:find_by).with(name: 'Student').and_return(student_role)

    student1 = double('User', id: 1, email: 'jane@example.com', first_name: 'Jane "JD"', last_name: 'Doe, Jr.')
    student2 = double('User', id: 2, email: 'bob@example.com', first_name: 'Bob', last_name: 'Smith')
    instructor = double('User', id: 3, email: 'prof@example.com', first_name: 'Prof', last_name: 'Oak')

    enrollment1 = double('CourseEnrollment', user_id: 1, user: student1, course_role_id: student_role.id)
    enrollment2 = double('CourseEnrollment', user_id: 2, user: student2, course_role_id: student_role.id)
    enrollment3 = double('CourseEnrollment', user_id: 3, user: instructor, course_role_id: 999)

    assign(:course_enrolled, [enrollment1, enrollment2, enrollment3])

    workout_offering1 = double('WorkoutOffering', workout: workout1, workout_id: 42, lti_assignment_id: nil)
    workout_offering2 = double('WorkoutOffering', workout: workout2, workout_id: 107, lti_assignment_id: nil)
    allow(course_offering).to receive(:workout_offerings).and_return([workout_offering1, workout_offering2])

    score1 = double('WorkoutScore', score: 95.5)
    score2 = double('WorkoutScore', score: 80.0)

    allow(WorkoutScore).to receive(:find_by).with(user_id: 1, workout: workout1, workout_offering: workout_offering1).and_return(score1)
    allow(WorkoutScore).to receive(:find_by).with(user_id: 1, workout: workout2, workout_offering: workout_offering2).and_return(score2)
    allow(WorkoutScore).to receive(:find_by).with(user_id: 2, workout: workout1, workout_offering: workout_offering1).and_return(nil)
    allow(WorkoutScore).to receive(:find_by).with(user_id: 2, workout: workout2, workout_offering: workout_offering2).and_return(nil)

    render
    lines = CSV.parse(rendered)

    expect(lines.size).to eq(3) # Header + 2 students (instructor excluded)
    expect(lines[1]).to eq(['jane@example.com', 'Jane "JD"', 'Doe, Jr.', '95.5', '80.0', '175.5'])
    expect(lines[2]).to eq(['bob@example.com', 'Bob', 'Smith', '', '', '0.0'])

    # Raw rendered string must contain CSV quote characters, NOT &quot; entities
    expect(rendered).to include('"Jane ""JD"""')
    expect(rendered).to include('"Doe, Jr."')
    expect(rendered).not_to include('&quot;')
  end

  it 'renders attempt columns with "#{wkt.name} (#{wkt.id}, try #{attempt_number})" when multiple attempts are allowed' do
    workout_offering1 = double(
      'WorkoutOffering',
      id: 501,
      workout: workout1,
      workout_id: 42,
      lti_assignment_id: nil,
      workout_attempt_limit: 3,
      student_extensions: []
    )
    workout_offering2 = double(
      'WorkoutOffering',
      id: 502,
      workout: workout2,
      workout_id: 107,
      lti_assignment_id: nil,
      workout_attempt_limit: 1,
      student_extensions: []
    )
    allow(course_offering).to receive(:workout_offerings).and_return([workout_offering1, workout_offering2])

    render
    lines = CSV.parse(rendered)
    header = lines[0]
    expect(header).to eq([
      'E-mail',
      'First Name',
      'Surname',
      'Variables and Types (42)',
      'Variables and Types (42, try 1)',
      'Variables and Types (42, try 2)',
      'Variables and Types (42, try 3)',
      'Loops and Conditionals (107)',
      'Total'
    ])
  end

  it "populates recorded and per-attempt scores correctly, leaving unused attempts blank" do
    student_role = CourseRole.find_by(name: 'Student') || double('CourseRole', id: 3)
    allow(CourseRole).to receive(:find_by).with(name: 'Student').and_return(student_role)

    student1 = double('User', id: 1, email: 'alice@example.com', first_name: 'Alice', last_name: 'Wonderland')
    student2 = double('User', id: 2, email: 'bob@example.com', first_name: 'Bob', last_name: 'Builder')

    enrollment1 = double('CourseEnrollment', user_id: 1, user: student1, course_role_id: student_role.id)
    enrollment2 = double('CourseEnrollment', user_id: 2, user: student2, course_role_id: student_role.id)
    assign(:course_enrolled, [enrollment1, enrollment2])

    workout_offering1 = double(
      'WorkoutOffering',
      id: 501,
      workout: workout1,
      workout_id: 42,
      lti_assignment_id: nil,
      workout_attempt_limit: 3,
      student_extensions: []
    )
    workout_offering2 = double(
      'WorkoutOffering',
      id: 502,
      workout: workout2,
      workout_id: 107,
      lti_assignment_id: nil,
      workout_attempt_limit: 1,
      student_extensions: []
    )
    allow(course_offering).to receive(:workout_offerings).and_return([workout_offering1, workout_offering2])

    # Student 1: 2 attempts on workout 1 (att1: 70.0, att2: 95.0, kept: 95.0), 1 attempt on workout 2 (80.0)
    w1_att1 = double('WorkoutScore', id: 10, workout_offering_id: 501, user_id: 1, attempt_number: 1, score: 70.0)
    w1_att2 = double('WorkoutScore', id: 11, workout_offering_id: 501, user_id: 1, attempt_number: 2, score: 95.0)
    w2_att1 = double('WorkoutScore', id: 12, workout_offering_id: 502, user_id: 1, attempt_number: 1, score: 80.0)

    # Student 2: 1 attempt on workout 1 (att1: 60.0), no attempts on workout 2
    w1_bob_att1 = double('WorkoutScore', id: 13, workout_offering_id: 501, user_id: 2, attempt_number: 1, score: 60.0)

    scores_hash = {
      [501, 1] => [w1_att1, w1_att2],
      [502, 1] => [w2_att1],
      [501, 2] => [w1_bob_att1]
    }
    assign(:scores_by_offering_and_user, scores_hash)

    allow(workout_offering1).to receive(:kept_score_from).with([w1_att1, w1_att2]).and_return(w1_att2)
    allow(workout_offering1).to receive(:kept_score_from).with([w1_bob_att1]).and_return(w1_bob_att1)
    allow(workout_offering2).to receive(:kept_score_from).with([w2_att1]).and_return(w2_att1)

    render
    lines = CSV.parse(rendered)

    expect(lines[0]).to eq([
      'E-mail',
      'First Name',
      'Surname',
      'Variables and Types (42)',
      'Variables and Types (42, try 1)',
      'Variables and Types (42, try 2)',
      'Variables and Types (42, try 3)',
      'Loops and Conditionals (107)',
      'Total'
    ])

    # Alice: w1 kept=95.0, try1=70.0, try2=95.0, try3="", w2 kept=80.0, total = 95.0 + 80.0 = 175.0
    expect(lines[1]).to eq(['alice@example.com', 'Alice', 'Wonderland', '95.0', '70.0', '95.0', '', '80.0', '175.0'])

    # Bob: w1 kept=60.0, try1=60.0, try2="", try3="", w2 kept="", total = 60.0
    expect(lines[2]).to eq(['bob@example.com', 'Bob', 'Builder', '60.0', '60.0', '', '', '', '60.0'])
  end
end
