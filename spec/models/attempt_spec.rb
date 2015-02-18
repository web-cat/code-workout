# == Schema Information
#
# Table name: attempts
#
#  id                  :integer          not null, primary key
#  user_id             :integer          not null
#  exercise_id         :integer          not null
#  submit_time         :datetime         not null
#  submit_num          :integer          not null
#  answer              :text
#  score               :decimal(, )      default(0.0)
#  experience_earned   :integer
#  created_at          :datetime
#  updated_at          :datetime
#  workout_offering_id :integer
#
# Indexes
#
#  index_attempts_on_exercise_id  (exercise_id)
#  index_attempts_on_user_id      (user_id)
#

require 'spec_helper'

describe Attempt do
  pending "add some examples to (or delete) #{__FILE__}"
end
