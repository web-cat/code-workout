# == Schema Information
#
# Table name: student_extensions
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  workout_offering_id :integer
#  soft_deadline       :datetime
#  hard_deadline       :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  time_limit          :integer
#  opening_date        :datetime
#
# Indexes
#
#  index_student_extensions_on_user_id              (user_id)
#  index_student_extensions_on_workout_offering_id  (workout_offering_id)
#

require 'rails_helper'

RSpec.describe StudentExtension, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
