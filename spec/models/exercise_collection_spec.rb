# == Schema Information
#
# Table name: exercise_collections
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  description   :text
#  user_group_id :integer
#  license_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_exercise_collections_on_license_id     (license_id)
#  index_exercise_collections_on_user_group_id  (user_group_id)
#

require 'spec_helper'

describe ExerciseCollection, :type => :model do
  before :all do
    @exercise_collection = ExerciseCollection.find(1)
    @user_group = UserGroup.find(1)
  end

  describe '#contains' do
    it 'should contain two exercises' do
      expect(@exercise_collection.exercises.count).to eq(2)
    end
  end

  describe '#edit-permissions' do

  end
end
