# == Schema Information
#
# Table name: base_exercises
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  question_type      :integer          not null
#  current_version_id :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#  versions           :integer          not null
#  variation_group_id :integer
#
# Indexes
#
#  index_base_exercises_on_current_version_id  (current_version_id)
#  index_base_exercises_on_user_id             (user_id)
#  index_base_exercises_on_variation_group_id  (variation_group_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :base_exercise do
    user_id 1
    question_type 1
    current_version 1
  end
end
