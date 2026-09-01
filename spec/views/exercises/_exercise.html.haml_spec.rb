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
end
