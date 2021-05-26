# == Schema Information
#
# Table name: workout_offering_score_summaries
#
#  id                  :integer          not null, primary key
#  all_students        :integer
#  full_score_students :integer
#  start_students      :integer
#  total_workout_score :float(24)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  workout_offering_id :integer
#
# Indexes
#
#  index_workout_offering_score_summaries_on_workout_offering_id  (workout_offering_id)
#
# Foreign Keys
#
#  fk_rails_...  (workout_offering_id => workout_offerings.id)
#

FactoryBot.define do
  factory :workout_offering_score_summary do
    start_students { 1 }
    all_students { 1 }
    total_workout_score { 1.5 }
    full_score_students { 1 }
    workout_offering { nil }
  end
end
