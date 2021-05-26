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

require 'rails_helper'

RSpec.describe WorkoutOfferingScoreSummary, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
