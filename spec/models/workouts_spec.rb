require 'spec_helper'

describe Workout, type: :model do
  describe ".find_by_id_or_name" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, slug: 'fall2026') }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 42, name: 'Recursion Practice') }

    it "finds a workout by its numeric primary key ID" do
      allow(Workout).to receive(:find_by).with(id: '42').and_return(workout)

      found = Workout.find_by_id_or_name('42')
      expect(found).to eq(workout)
    end

    it "finds a workout by its exact name" do
      relation = double('WorkoutRelation')
      allow(Workout).to receive(:where).with('lower(name) = ?', 'recursion practice').and_return(relation)
      allow(relation).to receive(:first).and_return(workout)

      found = Workout.find_by_id_or_name('Recursion Practice')
      expect(found).to eq(workout)
    end

    it "finds a workout by its parameterized name slug" do
      relation = double('WorkoutOfferingsRelation')
      allow(WorkoutOffering).to receive(:joins).with(:course_offering).and_return(relation)
      allow(relation).to receive(:where).with(
        course_offerings: { course_id: course.id, term_id: term.id }
      ).and_return(relation)
      allow(relation).to receive(:includes).with(:workout).and_return([double(workout: workout)])

      found = Workout.find_by_id_or_name('recursion-practice', course, term)
      expect(found).to eq(workout)
    end
  end

  describe "#workout_offering_for" do
    let(:organization) { FactoryBot.build_stubbed(:organization, slug: 'vt') }
    let(:course) { FactoryBot.build_stubbed(:course, id: 1, slug: 'cs1114', organization: organization) }
    let(:term) { FactoryBot.build_stubbed(:term, id: 2, slug: 'fall2026') }
    let(:workout) { FactoryBot.build_stubbed(:workout, id: 42, name: 'Recursion Practice') }
    let(:student) { FactoryBot.build_stubbed(:user, id: 10) }
    let(:instructor) { FactoryBot.build_stubbed(:user, id: 20) }

    let(:section1) { FactoryBot.build_stubbed(:course_offering, id: 101, course: course, term: term) }
    let(:section2) { FactoryBot.build_stubbed(:course_offering, id: 102, course: course, term: term) }

    let(:offering1) { FactoryBot.build_stubbed(:workout_offering, id: 201, workout: workout, course_offering: section1) }
    let(:offering2) { FactoryBot.build_stubbed(:workout_offering, id: 202, workout: workout, course_offering: section2) }

    it "finds the student's enrolled section workout offering" do
      allow(student).to receive(:course_offerings_for_term).with(term, course).and_return([section2])
      allow(WorkoutOffering).to receive(:where).with(
        course_offering_id: [102],
        workout_id: workout.id
      ).and_return([offering2])

      found = workout.workout_offering_for(student, course, term)
      expect(found).to eq(offering2)
    end

    it "finds a staff managed section workout offering when user is instructor" do
      allow(instructor).to receive(:course_offerings_for_term).with(term, course).and_return([])
      allow(instructor).to receive(:managed_course_offerings).with(course: course, term: term).and_return([section1, section2])
      allow(WorkoutOffering).to receive(:where).with(
        course_offering_id: [101, 102],
        workout_id: workout.id
      ).and_return([offering1, offering2])

      found = workout.workout_offering_for(instructor, course, term)
      expect(found).to eq(offering1)
    end

    it "returns the first available offering for the course if user is unenrolled" do
      unenrolled_user = FactoryBot.build_stubbed(:user, id: 99)
      allow(unenrolled_user).to receive(:course_offerings_for_term).with(term, course).and_return([])
      allow(unenrolled_user).to receive(:managed_course_offerings).with(course: course, term: term).and_return([])
      offerings_relation = double('WorkoutOfferingsRelation')
      allow(WorkoutOffering).to receive(:joins).with(:course_offering).and_return(offerings_relation)
      allow(offerings_relation).to receive(:where).with(
        course_offerings: { course_id: course.id, term_id: term.id },
        workout_id: workout.id
      ).and_return(double(first: offering1))

      found = workout.workout_offering_for(unenrolled_user, course, term)
      expect(found).to eq(offering1)
    end
  end
end
