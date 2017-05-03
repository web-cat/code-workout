# == Schema Information
#
# Table name: exercises
#
#  id                     :integer          not null, primary key
#  question_type          :integer          not null
#  current_version_id     :integer
#  created_at             :datetime
#  updated_at             :datetime
#  versions               :integer
#  exercise_family_id     :integer
#  name                   :string(255)
#  is_public              :boolean          default(FALSE), not null
#  experience             :integer          not null
#  irt_data_id            :integer
#  external_id            :string(255)
#  exercise_collection_id :integer
#
# Indexes
#
#  exercises_irt_data_id_fk                   (irt_data_id)
#  index_exercises_on_current_version_id      (current_version_id)
#  index_exercises_on_exercise_collection_id  (exercise_collection_id)
#  index_exercises_on_exercise_family_id      (exercise_family_id)
#  index_exercises_on_external_id             (external_id) UNIQUE
#  index_exercises_on_is_public               (is_public)
#

require 'spec_helper'

describe Exercise do
  before :all do
    @exercise = Exercise.find(1)
  end

  describe 'creator edit permissions' do
    it 'should be editable by the exercise creator' do
      user = @exercise.current_version.andand.creator
      expect(user.can?(:edit, @exercise)).to eq(true)
    end
  end
end
