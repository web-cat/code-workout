require 'spec_helper'

describe "workout_scores/_time_remaining.html.haml", type: :view do
  let(:user) { FactoryBot.build_stubbed(:user, id: 1) }
  let(:workout_offering) { FactoryBot.build_stubbed(:workout_offering, id: 20) }
  let(:now) { Time.zone.parse('2026-10-26 12:00:00') }
  let(:deadline) { now + 15.minutes }
  let(:workout_score) do
    FactoryBot.build_stubbed(
      :workout_score,
      user: user,
      workout_offering: workout_offering,
      started_at: now - 15.minutes
    )
  end

  it "renders nothing when workout_score is nil" do
    render partial: 'workout_scores/time_remaining', locals: { workout_score: nil }
    expect(rendered.strip).to be_empty
  end

  it "renders nothing when workout_score is closed" do
    allow(workout_score).to receive(:closed?).and_return(true)
    render partial: 'workout_scores/time_remaining', locals: { workout_score: workout_score }
    expect(rendered.strip).to be_empty
  end

  it "renders nothing when workout is untimed" do
    allow(workout_score).to receive(:closed?).and_return(false)
    allow(workout_score).to receive(:deadline).and_return(nil)
    render partial: 'workout_scores/time_remaining', locals: { workout_score: workout_score }
    expect(rendered.strip).to be_empty
  end

  it "renders user-deadline data, timer element, and timeout script when deadline is active" do
    allow(Time.zone).to receive(:now).and_return(now)
    allow(workout_score).to receive(:closed?).and_return(false)
    allow(workout_score).to receive(:deadline).and_return(deadline)

    render partial: 'workout_scores/time_remaining', locals: { workout_score: workout_score }

    expect(rendered).to have_selector('#user-deadline[data-deadline="2026-10-26T12:15:00"]', visible: false)
    expect(rendered).to have_selector('#user-deadline[data-server-now="2026-10-26T12:00:00"]', visible: false)
    expect(rendered).to have_selector('#timer.alert.alert-warning')
    expect(rendered).to include('Time remaining - ##:##')
    expect(rendered).to match(/timeout(-[a-f0-9]+)?\.js/)
  end
end
