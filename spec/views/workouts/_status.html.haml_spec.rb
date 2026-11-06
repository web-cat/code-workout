require 'spec_helper'

describe "workouts/_status.html.haml", type: :view do
  let(:user) { FactoryBot.build_stubbed(:user, id: 1) }
  let(:organization) { FactoryBot.build_stubbed(:organization, id: 1, slug: 'vt') }
  let(:course) { FactoryBot.build_stubbed(:course, id: 1, name: 'CS 1', slug: 'cs-1', organization: organization) }
  let(:term) { FactoryBot.build_stubbed(:term, id: 1, slug: 'f26') }
  let(:course_offering) { FactoryBot.build_stubbed(:course_offering, id: 1, course: course, term: term) }
  let(:workout) { FactoryBot.build_stubbed(:workout, id: 5, name: 'Test Workout') }
  let(:workout_offering) do
    FactoryBot.build_stubbed(
      :workout_offering,
      id: 12,
      workout: workout,
      course_offering: course_offering
    )
  end
  let(:exercise_version) do
    FactoryBot.build_stubbed(:exercise_version, id: 10).tap do |ev|
      allow(ev).to receive(:image_processing).and_return(true)
      allow(ev).to receive(:prompts).and_return([])
    end
  end
  let(:exercise1) do
    FactoryBot.build_stubbed(
      :exercise,
      id: 1,
      name: 'Exercise 1',
      current_version: exercise_version,
      current_version_id: 10,
      experience: 10
    ).tap do |ex|
      allow(ex).to receive(:tags).and_return([])
      allow(ex).to receive(:languages).and_return([])
    end
  end
  let(:exercise2) do
    FactoryBot.build_stubbed(
      :exercise,
      id: 2,
      name: 'Exercise 2',
      current_version: exercise_version,
      current_version_id: 10,
      experience: 10
    ).tap do |ex|
      allow(ex).to receive(:tags).and_return([])
      allow(ex).to receive(:languages).and_return([])
    end
  end
  let(:workout_score) do
    FactoryBot.build_stubbed(
      :workout_score,
      id: 99,
      workout_offering: workout_offering,
      workout: workout
    )
  end

  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(workout_score).to receive(:closed?).and_return(false)
    allow(workout_offering).to receive(:can_be_seen_by?).and_return(true)
    allow(workout_offering).to receive(:score_for).and_return(workout_score)
    allow(workout).to receive(:exercise_workouts).and_return(double(loaded?: false, where: double(first: nil)))
    allow(workout).to receive(:exercises).and_return([exercise1, exercise2])
    allow(workout_score).to receive(:exercises).and_return([exercise1, exercise2])
    allow(workout_score).to receive(:scoring_attempt_for).and_return(nil)
    allow(workout_score).to receive(:attempts).and_return(double(loaded?: false, where: double(any?: false)))
    stub_template 'workouts/_workout.html.haml' => '<div class="workout-summary">Workout Summary</div>'
  end

  it "renders navigation links for all exercises in the sidebar during active practice" do
    render partial: 'workouts/status', locals: {
      workout_score: workout_score,
      workout_offering: workout_offering,
      review: false
    }

    url1 = organization_workout_offering_exercise_path(
      id: exercise1.id,
      organization_id: organization.slug,
      course_id: course.slug,
      term_id: term.slug,
      workout_offering_id: workout_offering.id,
      workout_score_id: workout_score.id
    )
    url2 = organization_workout_offering_exercise_path(
      id: exercise2.id,
      organization_id: organization.slug,
      course_id: course.slug,
      term_id: term.slug,
      workout_offering_id: workout_offering.id,
      workout_score_id: workout_score.id
    )

    expect(rendered).to have_link(exercise1.display_name, href: url1)
    expect(rendered).to have_link(exercise2.display_name, href: url2)
  end
end
