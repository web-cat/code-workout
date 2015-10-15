# == Schema Information
#
# Table name: attempts
#
#  id                  :integer          not null, primary key
#  user_id             :integer          not null
#  exercise_version_id :integer          not null
#  submit_time         :datetime         not null
#  submit_num          :integer          not null
#  score               :float(24)        default(0.0)
#  experience_earned   :integer
#  created_at          :datetime
#  updated_at          :datetime
#  workout_score_id    :integer
#  active_score_id     :integer
#  feedback_ready      :boolean
#
# Indexes
#
#  index_attempts_on_active_score_id      (active_score_id)
#  index_attempts_on_exercise_version_id  (exercise_version_id)
#  index_attempts_on_user_id              (user_id)
#  index_attempts_on_workout_score_id     (workout_score_id)
#

require 'spec_helper'

describe Attempt do
  pending "add some examples to (or delete) #{__FILE__}"
end
