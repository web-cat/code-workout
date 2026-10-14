require 'spec_helper'

describe CoursesHelper, type: :helper do
  describe '#course_workout_items' do
    let(:now) { Time.zone.parse('2026-10-14 12:00:00') }
    let(:user) { double('User', id: 1) }

    it 'returns empty array when course_offerings is blank' do
      expect(helper.course_workout_items([], user, false, now)).to eq([])
      expect(helper.course_workout_items(nil, user, false, now)).to eq([])
    end

    it 'sorts workouts in due date order by default with nil due dates at the end' do
      w1 = double('Workout', id: 101, name: 'Workout B')
      w2 = double('Workout', id: 102, name: 'Workout A')
      w3 = double('Workout', id: 103, name: 'Workout C')

      # w1 due earlier (Oct 15)
      wo1 = double('WorkoutOffering', id: 1, workout_id: 101, workout: w1,
                   opening_date: now - 5.days, soft_deadline: now + 1.day, hard_deadline: now + 5.days, published: true)
      # w2 due later (Oct 20)
      wo2 = double('WorkoutOffering', id: 2, workout_id: 102, workout: w2,
                   opening_date: now - 5.days, soft_deadline: now + 6.days, hard_deadline: now + 10.days, published: true)
      # w3 no due date
      wo3 = double('WorkoutOffering', id: 3, workout_id: 103, workout: w3,
                   opening_date: nil, soft_deadline: nil, hard_deadline: nil, published: true)

      co = double('CourseOffering', id: 1, workout_offerings: [wo2, wo3, wo1])

      items = helper.course_workout_items([co], user, false, now)
      expect(items.map { |i| i[:workout].id }).to eq([101, 102, 103])
    end

    it 'correctly computes states: open, past, future, past_due, published, unpublished' do
      # 1. Open and not past due
      w_open = double('Workout', id: 1, name: 'Open Workout')
      wo_open = double('WorkoutOffering', id: 11, workout_id: 1, workout: w_open,
                       opening_date: now - 2.days, soft_deadline: now + 2.days, hard_deadline: now + 4.days, published: true)

      # 2. Open but past due (soft deadline passed, hard deadline in future)
      w_past_due = double('Workout', id: 2, name: 'Past Due Workout')
      wo_past_due = double('WorkoutOffering', id: 12, workout_id: 2, workout: w_past_due,
                           opening_date: now - 5.days, soft_deadline: now - 1.day, hard_deadline: now + 2.days, published: true)

      # 3. Past (hard deadline passed)
      w_past = double('Workout', id: 3, name: 'Past Workout')
      wo_past = double('WorkoutOffering', id: 13, workout_id: 3, workout: w_past,
                       opening_date: now - 10.days, soft_deadline: now - 5.days, hard_deadline: now - 2.days, published: true)

      # 4. Future (opening date in future)
      w_future = double('Workout', id: 4, name: 'Future Workout')
      wo_future = double('WorkoutOffering', id: 14, workout_id: 4, workout: w_future,
                         opening_date: now + 2.days, soft_deadline: now + 7.days, hard_deadline: now + 9.days, published: false)

      co = double('CourseOffering', id: 1, workout_offerings: [wo_open, wo_past_due, wo_past, wo_future])

      items = helper.course_workout_items([co], user, false, now).index_by { |i| i[:workout].id }

      # Open workout
      expect(items[1][:is_open]).to be true
      expect(items[1][:is_past]).to be false
      expect(items[1][:is_future]).to be false
      expect(items[1][:is_past_due]).to be false
      expect(items[1][:is_published]).to be true
      expect(items[1][:is_unpublished]).to be false

      # Past due workout
      expect(items[2][:is_open]).to be true
      expect(items[2][:is_past]).to be false
      expect(items[2][:is_future]).to be false
      expect(items[2][:is_past_due]).to be true

      # Past workout
      expect(items[3][:is_open]).to be false
      expect(items[3][:is_past]).to be true
      expect(items[3][:is_future]).to be false
      expect(items[3][:is_past_due]).to be true

      # Future & unpublished workout
      expect(items[4][:is_open]).to be false
      expect(items[4][:is_past]).to be false
      expect(items[4][:is_future]).to be true
      expect(items[4][:is_past_due]).to be false
      expect(items[4][:is_published]).to be false
      expect(items[4][:is_unpublished]).to be true
    end

    it 'aggregates min from date, max closed date, and due date across multiple offerings of the same workout' do
      w = double('Workout', id: 50, name: 'Multi Section Workout')

      # Section 1: opens 5 days ago, due in 2 days, closed in 4 days
      wo_sec1 = double('WorkoutOffering', id: 21, workout_id: 50, workout: w,
                       opening_date: now - 5.days, soft_deadline: now + 2.days, hard_deadline: now + 4.days, published: true)

      # Section 2: opens 8 days ago (earlier min_from), due in 3 days, closed in 6 days (later max_closed)
      wo_sec2 = double('WorkoutOffering', id: 22, workout_id: 50, workout: w,
                       opening_date: now - 8.days, soft_deadline: now + 3.days, hard_deadline: now + 6.days, published: false)

      co1 = double('CourseOffering', id: 1, workout_offerings: [wo_sec1])
      co2 = double('CourseOffering', id: 2, workout_offerings: [wo_sec2])

      items = helper.course_workout_items([co1, co2], user, false, now)
      expect(items.size).to eq(1)
      item = items.first
      expect(item[:min_from]).to eq(now - 8.days)
      expect(item[:max_closed]).to eq(now + 6.days)
      expect(item[:due_date]).to eq(now + 2.days)
      expect(item[:is_published]).to be true
      expect(item[:is_unpublished]).to be true
    end

    it 'respects student extensions and visibility for students' do
      w = double('Workout', id: 60, name: 'Student Workout')
      wo = double('WorkoutOffering', id: 31, workout_id: 60, workout: w,
                  published: true)

      allow(wo).to receive(:can_be_seen_by?).with(user).and_return(true)
      allow(wo).to receive(:opening_date_for).with(user).and_return(now - 1.day)
      allow(wo).to receive(:hard_deadline_for).with(user).and_return(now + 10.days)
      ext = double('StudentExtension', soft_deadline: now + 5.days)
      allow(wo).to receive(:extension_for).with(user).and_return(ext)

      co = double('CourseOffering', id: 1, workout_offerings: [wo])
      items = helper.course_workout_items([co], user, true, now)
      expect(items.size).to eq(1)
      item = items.first
      expect(item[:due_date]).to eq(now + 5.days)
      expect(item[:max_closed]).to eq(now + 10.days)
      expect(item[:min_from]).to eq(now - 1.day)
    end
  end
end
