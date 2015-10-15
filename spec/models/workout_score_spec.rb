# == Schema Information
#
# Table name: workout_scores
#
#  id                  :integer          not null, primary key
#  workout_id          :integer          not null
#  user_id             :integer          not null
#  score               :float(24)
#  completed           :boolean
#  completed_at        :datetime
#  last_attempted_at   :datetime
#  exercises_completed :integer
#  exercises_remaining :integer
#  created_at          :datetime
#  updated_at          :datetime
#  workout_offering_id :integer
#
# Indexes
#
#  index_workout_scores_on_user_id     (user_id)
#  index_workout_scores_on_workout_id  (workout_id)
#

require 'rails_helper'

RSpec.describe WorkoutScore, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
