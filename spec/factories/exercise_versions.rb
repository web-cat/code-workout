# == Schema Information
#
# Table name: exercise_versions
#
#  id          :integer          not null, primary key
#  stem_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  exercise_id :integer          not null
#  version     :integer          not null
#  creator_id  :integer
#  irt_data_id :integer
#
# Indexes
#
#  index_exercise_versions_on_exercise_id  (exercise_id)
#  index_exercise_versions_on_stem_id      (stem_id)
#

FactoryGirl.define do
  factory :exercise_version do
  end
end
