require 'spec_helper'

describe "exercises/_exercise.html.haml" do
  let(:exercise_version) do
    FactoryBot.build_stubbed(:exercise_version, id: 10).tap do |ev|
      allow(ev).to receive(:image_processing).and_return(true)
      allow(ev).to receive(:prompts).and_return([])
    end
  end

  let(:exercise) do
    FactoryBot.build_stubbed(
      :exercise,
      id: 1,
      name: 'Sample Exercise',
      current_version: exercise_version,
      current_version_id: 10,
      experience: 10
    ).tap do |ex|
      allow(ex).to receive(:tags).and_return([])
      allow(ex).to receive(:languages).and_return([])
    end
  end

  it "renders without error when workout_offering is not provided" do
    allow(view).to receive(:current_user).and_return(nil)
    expect {
      render partial: 'exercises/exercise', locals: { exercise: exercise }
    }.not_to raise_error
  end

  it "renders without error when workout_offering is nil and user is signed in" do
    user = FactoryBot.build_stubbed(:user)
    allow(view).to receive(:current_user).and_return(user)
    expect {
      render partial: 'exercises/exercise', locals: { exercise: exercise, user: user, workout_offering: nil }
    }.not_to raise_error
  end

  context "when workout_offering is provided" do
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
    let(:workout_score) { FactoryBot.build_stubbed(:workout_score, id: 99, workout_offering: workout_offering, workout: workout) }

    before do
      allow(view).to receive(:current_user).and_return(user)
      allow(workout_offering).to receive(:can_be_seen_by?).and_return(true)
      allow(workout_offering).to receive(:score_for).and_return(workout_score)
      allow(workout).to receive(:exercise_workouts).and_return(double(loaded?: false, where: double(first: nil)))
      allow(workout_score).to receive(:scoring_attempt_for).and_return(nil)
      allow(workout_score).to receive(:attempts).and_return(double(loaded?: false, where: double(any?: false)))
    end

    it "renders a clickable link to the exercise when start_workout is not specified (e.g. sidebar navigation during practice)" do
      render partial: 'exercises/exercise', locals: {
        exercise: exercise,
        user: user,
        workout_offering: workout_offering,
        workout_score: workout_score,
        workout: workout,
        review: false
      }

      expected_url = organization_workout_offering_exercise_path(
        id: exercise.id,
        organization_id: organization.slug,
        course_id: course.slug,
        term_id: term.slug,
        workout_offering_id: workout_offering.id,
        workout_score_id: workout_score.id
      )
      expect(rendered).to have_link(exercise.display_name, href: expected_url)
    end

    it "renders unclickable plain text when start_workout is false and review is false" do
      render partial: 'exercises/exercise', locals: {
        exercise: exercise,
        user: user,
        workout_offering: workout_offering,
        workout_score: workout_score,
        workout: workout,
        start_workout: false,
        review: false
      }

      expect(rendered).to have_content(exercise.display_name)
      expect(rendered).not_to have_link(exercise.display_name)
    end

    it "renders a link to start/practice the workout offering when start_workout is true" do
      render partial: 'exercises/exercise', locals: {
        exercise: exercise,
        user: user,
        workout_offering: workout_offering,
        workout_score: workout_score,
        workout: workout,
        start_workout: true,
        review: false
      }

      expected_url = organization_workout_offering_practice_path(
        exercise_id: exercise.id,
        organization_id: organization.slug,
        course_id: course.slug,
        term_id: term.slug,
        id: workout_offering.id,
        workout_score_id: workout_score.id
      )
      expect(rendered).to have_link(exercise.display_name, href: expected_url)
    end
  end
end
