require 'spec_helper'
require 'cancan/matchers'

describe Ability, type: :model do
  describe 'Workout permissions' do
    let(:user) { FactoryBot.build_stubbed(:user) }
    let(:other_user) { FactoryBot.build_stubbed(:user) }
    let(:workout) { FactoryBot.build_stubbed(:workout, creator_id: other_user.id) }
    subject(:ability) { Ability.new(user) }

    before do
      allow(user).to receive(:global_role).and_return(GlobalRole.regular_user)
      allow(user).to receive(:instructor_course_offerings).and_return([])
      allow(user).to receive(:managed_workouts).and_return([])
      allow(workout).to receive(:owners).and_return([])
    end

    it 'allows creator to update the workout' do
      workout.creator_id = user.id
      expect(ability).to be_able_to(:update, workout)
    end

    it 'allows workout owner to update the workout' do
      allow(workout).to receive(:owners).and_return([user])
      expect(ability).to be_able_to(:update, workout)
    end

    it 'allows user with managed workout to update the workout' do
      allow(user).to receive(:managed_workouts).and_return([workout])
      expect(ability).to be_able_to(:update, workout)
    end

    it 'disallows regular user who is not creator, owner, or manager' do
      expect(ability).not_to be_able_to(:update, workout)
    end
  end
end
