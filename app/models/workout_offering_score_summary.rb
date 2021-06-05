# == Schema Information
#
# Table name: workout_offering_score_summaries
#
#  id                    :integer          not null, primary key
#  average_workout_score :float(24)
#  full_score_students   :float(24)
#  mark                  :boolean
#  start_students        :float(24)
#  total_students        :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  workout_offering_id   :integer
#
# Indexes
#
#  index_workout_offering_score_summaries_on_workout_offering_id  (workout_offering_id)
#

class WorkoutOfferingScoreSummary < ActiveRecord::Base
  belongs_to :workout_offering
end


# all_students int
# flag boolean

