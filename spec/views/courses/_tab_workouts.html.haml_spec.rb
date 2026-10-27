require 'spec_helper'

describe "courses/_tab_workouts.html.haml", type: :view do
  let(:now) { Time.zone.now }
  let(:user) { double('User', id: 1, global_role: double('GlobalRole', is_admin?: false), time_zone: double('TimeZone', name: 'UTC')) }
  let(:org) { double('Organization', id: 1, slug: 'cs') }
  let(:course) { double('Course', id: 1, slug: 'cs-1114', organization: org) }
  let(:term) { double('Term', id: 1, slug: 'fa26') }

  let(:workout1) { double('Workout', id: 101, name: 'Binary Trees', description: 'Trees intro', total_points: 10, exercises: [], highest_difficulty: 1, tags: [], num_exercises: 0) }
  let(:workout2) { double('Workout', id: 102, name: 'Array Lists', description: 'Arrays intro', total_points: 10, exercises: [], highest_difficulty: 1, tags: [], num_exercises: 0) }

  let(:wo1) do
    double('WorkoutOffering',
      id: 1,
      workout_id: 101,
      workout: workout1,
      opening_date: now - 3.days,
      soft_deadline: now + 5.days, # due later
      hard_deadline: now + 10.days,
      published: true,
      current_deadline_distance: 4
    )
  end

  let(:wo2) do
    double('WorkoutOffering',
      id: 2,
      workout_id: 102,
      workout: workout2,
      opening_date: now - 5.days,
      soft_deadline: now + 1.day, # due sooner
      hard_deadline: now + 4.days,
      published: true,
      current_deadline_distance: 4
    )
  end

  let(:course_offering) do
    co = double('CourseOffering', id: 1, course: course, term: term, display_name: 'Section 1')
    allow(wo1).to receive(:course_offering).and_return(co)
    allow(wo2).to receive(:course_offering).and_return(co)
    allow(co).to receive(:workout_offerings).and_return([wo1, wo2])
    co
  end

  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:markdown) { |text| text }
    allow(WorkoutScore).to receive(:find_by).and_return(nil)
    allow(workout1).to receive(:score_for).and_return(nil)
    allow(workout2).to receive(:score_for).and_return(nil)
    allow(workout1).to receive(:to_partial_path).and_return('workouts/workout')
    allow(workout2).to receive(:to_partial_path).and_return('workouts/workout')
    allow(wo1).to receive(:to_partial_path).and_return('workout_offerings/workout_offering')
    allow(wo2).to receive(:to_partial_path).and_return('workout_offerings/workout_offering')
    allow(workout1).to receive(:andand).and_return(workout1)
    allow(workout2).to receive(:andand).and_return(workout2)
    allow(wo1).to receive(:andand).and_return(wo1)
    allow(wo2).to receive(:andand).and_return(wo2)
  end

  it 'renders the toolbar with name filter, state filter dropdown, and sort select' do
    render partial: 'courses/tab_workouts', locals: {
      is_student: false,
      course_offerings: [course_offering],
      course: course,
      term: term,
      organization: org
    }

    # Toolbar
    expect(rendered).to have_selector('.workouts-toolbar')

    # Dynamic name filter
    expect(rendered).to have_selector('#workout-filter-name')
    expect(rendered).to have_selector('.workout-clear-name')

    # State filter dropdown
    expect(rendered).to have_selector('#workout-state-filter-btn')
    expect(rendered).to have_selector('.workout-state-checkbox[value="open"]')
    expect(rendered).to have_selector('.workout-state-checkbox[value="past_due"]')
    expect(rendered).to have_selector('.workout-state-checkbox[value="past"]')
    expect(rendered).to have_selector('.workout-state-checkbox[value="future"]')
    expect(rendered).to have_selector('.workout-state-checkbox[value="published"]')
    expect(rendered).to have_selector('.workout-state-checkbox[value="unpublished"]')
    expect(rendered).to have_selector('.workout-state-reset')

    # Sort select
    expect(rendered).to have_selector('#workout-sort-select')
    expect(rendered).to have_selector('#workout-sort-select option[value="due-asc"]')
    expect(rendered).to have_selector('#workout-sort-select option[value="open-asc"]')
    expect(rendered).to have_selector('#workout-sort-select option[value="name-asc"]')

    # Add workout button
    expect(rendered).to have_link('Add Workout')
  end

  it 'orders workout cards by default in due date order' do
    render partial: 'courses/tab_workouts', locals: {
      is_student: false,
      course_offerings: [course_offering],
      course: course,
      term: term,
      organization: org
    }

    # wo2 (due sooner) should appear before wo1 (due later)
    expect(rendered).to have_selector('.workouts-list .workout-card', count: 2)
    cards = Capybara.string(rendered).all('.workouts-list .workout-card')
    expect(cards[0][:id]).to eq('workout-card-102')
    expect(cards[1][:id]).to eq('workout-card-101')
  end

  it 'populates workout cards with data attributes for filtering and sorting' do
    render partial: 'courses/tab_workouts', locals: {
      is_student: false,
      course_offerings: [course_offering],
      course: course,
      term: term,
      organization: org
    }

    card = Capybara.string(rendered).find('#workout-card-102')
    expect(card['data-workout-name']).to eq('array lists')
    expect(card['data-is-open']).to eq('true')
    expect(card['data-is-past']).to eq('false')
    expect(card['data-is-published']).to eq('true')
    expect(card['data-is-unpublished']).to eq('false')
    expect(card['data-due-date']).not_to be_empty
  end
end
