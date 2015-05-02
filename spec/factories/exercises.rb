# == Schema Information
#
# Table name: exercises
#
#  id                 :integer          not null, primary key
#  question_type      :integer          not null
#  current_version_id :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#  versions           :integer          not null
#  exercise_family_id :integer
#  name               :string(255)
#  is_public          :boolean          default(FALSE), not null
#  experience         :integer          not null
#  attempt_count      :integer          default(0), not null
#  correct_count      :float            default(0.0), not null
#  difficulty         :float            default(0.0), not null
#  discrimination     :float            default(0.0), not null
#
# Indexes
#
#  index_exercises_on_current_version_id  (current_version_id)
#  index_exercises_on_exercise_family_id  (exercise_family_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

#FactoryGirl.define do
#  factory :exercise do
#  end
#end
