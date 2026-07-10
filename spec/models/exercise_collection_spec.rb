# == Schema Information
#
# Table name: exercise_collections
#
#  id                 :bigint           not null, primary key
#  description        :text(65535)
#  name               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  course_offering_id :bigint
#  license_id         :bigint
#  user_group_id      :bigint
#  user_id            :bigint
#
# Indexes
#
#  index_exercise_collections_on_course_offering_id  (course_offering_id)
#  index_exercise_collections_on_license_id          (license_id)
#  index_exercise_collections_on_user_group_id       (user_group_id)
#  index_exercise_collections_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (course_offering_id => course_offerings.id)
#  fk_rails_...  (license_id => licenses.id)
#  fk_rails_...  (user_group_id => user_groups.id)
#  fk_rails_...  (user_id => users.id)
#

require 'spec_helper'

describe ExerciseCollection, :type => :model do
  before :all do
    @exercise_collection = ExerciseCollection.find(1)
    @user_group = @exercise_collection.user_group
  end

  describe 'contains' do
    it 'should contain two exercises' do
      expect(@exercise_collection.exercises.count).to eq(2)
    end
  end

  describe 'group edit permissions' do
    context 'collection belongs to a group' do
      before :all do
        @exercise_collection = ExerciseCollection.find(1)
        @user_group = @exercise_collection.user_group
      end

      it 'should let a group member edit an exercise from the collection' do
        member = @user_group.users.where.not(global_role: GlobalRole.administrator).first
        expect(member.can?(:edit, @exercise_collection.exercises.first)).to be_falsey
      end

      it 'should not let an outsider edit an exercise from the collection' do
        outside_user = User.not_in_group(@user_group).where.not(global_role: GlobalRole.administrator).first
        expect(outside_user.can?(:edit, @exercise_collection.exercises.first)).to be_falsey
      end
    end

    context 'collection belongs to a single user' do
      before :all do
        @exercise_collection = ExerciseCollection.find(2)
        @user = @exercise_collection.user
      end

      it 'should allow a collection owner to edit the exercise from the collection' do
        expect(@user.can?(:edit, @exercise_collection.exercises.first)).to be_falsey
      end

      it "should not allow a second user to edit an exercise from another user's owned collection" do
        second_user = User.where.not(id: @user.id).where.not(global_role: GlobalRole.administrator).first
        expect(second_user.can?(:edit, @exercise_collection.exercises.first)).to be_falsey
      end
    end
  end
end
