# == Schema Information
#
# Table name: workout_offering_score_summaries
#
#  id                    :integer          not null, primary key
#  average_workout_score :float(24)
#  full_score_students   :float(24)
#  mark                  :boolean
#  start_students        :float(24)
#  start_students_int    :integer
#  total_students        :integer
#  workout_full_score    :float(24)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  workout_offering_id   :integer
#
# Indexes
#
#  index_workout_offering_score_summaries_on_workout_offering_id  (workout_offering_id)
#

FactoryBot.define do
  factory :workout_offering_score_summary do
    start_students { 1.5 }
    average_workout_score { 1.5 }
    full_score_students { 1.5 }
  end
end
