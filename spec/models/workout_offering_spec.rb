# == Schema Information
#
# Table name: workout_offerings
#
#  id                 :integer          not null, primary key
#  course_offering_id :integer
#  workout_id         :integer
#  created_at         :datetime
#  updated_at         :datetime
#  opening_date       :date
#  soft_deadline      :date
#  hard_deadline      :date
#

require 'rails_helper'

RSpec.describe WorkoutOffering, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
