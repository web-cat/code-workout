# == Schema Information
#
# Table name: workout_scores
#
#  id                      :integer          not null, primary key
#  workout_id              :integer          not null
#  user_id                 :integer          not null
#  score                   :float(24)
#  completed               :boolean
#  completed_at            :datetime
#  last_attempted_at       :datetime
#  exercises_completed     :integer
#  exercises_remaining     :integer
#  created_at              :datetime
#  updated_at              :datetime
#  workout_offering_id     :integer
#  lis_outcome_service_url :string(255)
#  lis_result_sourcedid    :string(255)
#
# Indexes
#
#  index_workout_scores_on_user_id        (user_id)
#  index_workout_scores_on_workout_id     (workout_id)
#  workout_scores_workout_offering_id_fk  (workout_offering_id)
#

require 'rails_helper'

RSpec.describe WorkoutScore, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
