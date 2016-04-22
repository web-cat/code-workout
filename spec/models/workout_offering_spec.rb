# == Schema Information
#
# Table name: workout_offerings
#
#  id                       :integer          not null, primary key
#  course_offering_id       :integer          not null
#  workout_id               :integer          not null
#  created_at               :datetime
#  updated_at               :datetime
#  opening_date             :datetime
#  soft_deadline            :datetime
#  hard_deadline            :datetime
#  published                :boolean          default(FALSE), not null
#  time_limit               :integer
#  workout_policy_id        :integer
#  continue_from_workout_id :integer
#
# Indexes
#
#  index_workout_offerings_on_course_offering_id  (course_offering_id)
#  index_workout_offerings_on_workout_id          (workout_id)
#  index_workout_offerings_on_workout_policy_id   (workout_policy_id)
#  workout_offerings_continue_from_workout_id_fk  (continue_from_workout_id)
#

require 'rails_helper'

RSpec.describe WorkoutOffering, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
