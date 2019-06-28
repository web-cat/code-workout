# == Schema Information
#
# Table name: visualization_loggings
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  exercise_id         :integer
#  workout_id          :integer
#  workout_offering_id :integer
#  created_at          :datetime
#  updated_at          :datetime
#
# Indexes
#
#  index_visualization_loggings_on_exercise_id          (exercise_id)
#  index_visualization_loggings_on_user_id              (user_id)
#  index_visualization_loggings_on_workout_id           (workout_id)
#  index_visualization_loggings_on_workout_offering_id  (workout_offering_id)
#

require 'rails_helper'

RSpec.describe VisualizationLogging, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
