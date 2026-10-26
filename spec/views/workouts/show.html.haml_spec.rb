require 'spec_helper'

describe "workouts/show", type: :view do
  let(:user) { FactoryBot.build_stubbed(:user, id: 1) }
  let(:organization) { FactoryBot.build_stubbed(:organization, id: 1, slug: 'vt') }
  let(:course) { FactoryBot.build_stubbed(:course, id: 1, name: 'CS 1', slug: 'cs-1', organization: organization) }
  let(:term) { FactoryBot.build_stubbed(:term, id: 1, slug: 'f26') }
  let(:course_offering) { FactoryBot.build_stubbed(:course_offering, id: 1, course: course, term: term) }
  let(:workout) { FactoryBot.build_stubbed(:workout, id: 1, name: 'Test Workout', description: 'Desc') }
  let(:workout_offering) do
    FactoryBot.build_stubbed(
      :workout_offering,
      id: 1,
      workout: workout,
      course_offering: course_offering
    )
  end
  let(:exercise1) { FactoryBot.build_stubbed(:exercise, id: 1, name: 'Exercise 1') }
  let(:exercise2) { FactoryBot.build_stubbed(:exercise, id: 2, name: 'Exercise 2') }

  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:markdown) { |text| text }
    allow(view).to receive(:user_time) { |_u, t| t }
    allow(view).to receive(:url_for).and_return('/workouts/1')
    stub_template 'layouts/_breadcrumb.html.haml' => ''
    stub_template 'workout_scores/_time_remaining.html.haml' => ''
    stub_template 'exercises/_exercise.html.haml' => '<div class="exercise-thumbnail">Exercise</div>'

    assign(:workout, workout)
    assign(:workout_offering, workout_offering)
    assign(:organization, organization)
    assign(:course, course)
    assign(:term, term)
    assign(:exs, [exercise1])

    allow(workout).to receive(:tags).and_return([])
    allow(workout).to receive(:workout_offerings).and_return([])
    allow(workout).to receive(:owners).and_return(double(exists?: false))
    allow(workout).to receive(:creator).and_return(nil)
    allow(workout_offering).to receive(:scores_for).and_return([])
    allow(workout_offering).to receive(:active_score_for).and_return(nil)
    allow(workout_offering).to receive(:time_limit_for).and_return(nil)
    allow(workout_offering).to receive(:can_start_new_attempt?).and_return(false)
    allow(workout_offering).to receive(:attempts_allowed_for).and_return(1)
    allow(workout_offering).to receive(:can_be_seen_by?).and_return(true)
    allow(workout_offering).to receive(:kept_workout_score_for).and_return(nil)
    allow(workout_offering).to receive(:latest_score_for).and_return(nil)
    allow(course_offering).to receive(:is_staff?).and_return(false)
    allow(course_offering).to receive(:is_manager?).and_return(false)
  end

  context "when policy indicates student cannot see answers after finishing (see_answers: false)" do
    before do
      workout_offering.workout_policy = WorkoutPolicy.new(see_answers: false)
    end

    it "shows exercise count and does not render exercise thumbnails" do
      render
      expect(rendered).to include("This workout contains 1 exercise.")
      expect(rendered).not_to include("class=\"exercise-thumbnail\"")
    end

    it "properly pluralizes the count when there are multiple exercises" do
      assign(:exs, [exercise1, exercise2])
      render
      expect(rendered).to include("This workout contains 2 exercises.")
      expect(rendered).not_to include("class=\"exercise-thumbnail\"")
    end

    it "allows managers to see exercise thumbnails" do
      allow(course_offering).to receive(:is_manager?).with(user).and_return(true)
      render
      expect(rendered).to include("class=\"exercise-thumbnail\"")
      expect(rendered).not_to include("This workout contains")
    end

    it "hides exercise thumbnails when a manager previews as student" do
      allow(course_offering).to receive(:is_manager?).with(user).and_return(true)
      allow(course_offering).to receive(:is_staff?).with(user).and_return(true)
      assign(:can_view_as_student, true)
      assign(:as_student, true)
      render
      expect(rendered).to include("This workout contains 1 exercise.")
      expect(rendered).not_to include("class=\"exercise-thumbnail\"")
    end
  end

  context "when policy indicates student answers are hidden until everyone finishes (no_review_before_close: true)" do
    before do
      workout_offering.workout_policy = WorkoutPolicy.new(no_review_before_close: true)
      allow(workout_offering).to receive(:shutdown?).and_return(false)
    end

    it "shows exercise count and does not render exercise thumbnails before close" do
      render
      expect(rendered).to include("This workout contains 1 exercise.")
      expect(rendered).not_to include("class=\"exercise-thumbnail\"")
    end

    it "shows alert when workout score is closed" do
      score = double("WorkoutScore", id: 1, closed?: true, score: 10, show_score?: false, updated_at: Time.current, attempt_number: 1)
      assign(:workout_score, score)
      render
      expect(rendered).to include("This workout contains 1 exercise.")
      expect(rendered).to include("Results will be visible after the assignment closes.")
      expect(rendered).not_to include("class=\"exercise-thumbnail\"")
    end

    it "renders exercise thumbnails after the assignment has closed (shutdown)" do
      allow(workout_offering).to receive(:shutdown?).and_return(true)
      render
      expect(rendered).to include("class=\"exercise-thumbnail\"")
      expect(rendered).not_to include("This workout contains 1 exercise.")
    end
  end

  context "when policy allows viewing answers" do
    before do
      workout_offering.workout_policy = WorkoutPolicy.new(see_answers: true, no_review_before_close: false)
    end

    it "renders the exercise thumbnails" do
      render
      expect(rendered).to include("class=\"exercise-thumbnail\"")
      expect(rendered).not_to include("This workout contains 1 exercise.")
    end

    it "shows warning when no exercises are in the workout" do
      assign(:exs, [])
      render
      expect(rendered).to include("No exercises in this workout")
    end
  end
end
