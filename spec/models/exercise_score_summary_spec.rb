# == Schema Information
#
# Table name: exercise_score_summaries
#
#  id                     :integer          not null, primary key
#  average_exercise_score :float(24)
#  full_score_students    :float(24)
#  mark                   :boolean
#  start_students         :float(24)
#  total_students         :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  exercise_id            :integer
#  workout_offering_id    :integer
#
# Indexes
#
#  index_exercise_score_summaries_on_exercise_id          (exercise_id)
#  index_exercise_score_summaries_on_workout_offering_id  (workout_offering_id)
#

require 'rails_helper'

RSpec.describe ExerciseScoreSummary, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
