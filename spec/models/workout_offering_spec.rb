require 'spec_helper'

describe WorkoutOffering, type: :model do
  describe "#can_be_practiced_by?" do
    let(:user) { FactoryBot.build_stubbed(:user, id: 1) }
    let(:course_offering) { FactoryBot.build_stubbed(:course_offering, id: 10) }
    let(:workout_offering) do
      FactoryBot.build_stubbed(
        :workout_offering,
        id: 20,
        course_offering: course_offering,
        opening_date: 2.days.ago,
        soft_deadline: 2.days.from_now,
        hard_deadline: 3.days.from_now
      )
    end

    before do
      allow(course_offering).to receive(:is_enrolled?).with(user).and_return(true)
      allow(course_offering).to receive(:is_staff?).with(user).and_return(false)
      allow(workout_offering).to receive(:workout_scores).and_return(double(where: double(last: nil), loaded?: false))
    end

    it "returns true when within open dates and hard deadline" do
      allow(workout_offering).to receive(:student_extensions).and_return([])
      expect(workout_offering.can_be_practiced_by?(user)).to be true
    end

    it "honors opening_date and hard_deadline from student_extensions" do
      extension = FactoryBot.build_stubbed(
        :student_extension,
        user: user,
        workout_offering: workout_offering,
        opening_date: 5.days.ago,
        hard_deadline: 7.days.from_now
      )
      allow(workout_offering).to receive(:student_extensions).and_return([extension])
      expect(workout_offering.can_be_practiced_by?(user)).to be true
    end
  end
end
