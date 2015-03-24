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

class WorkoutOffering < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :workout, inverse_of: :workout_offerings
  belongs_to :course_offering, inverse_of: :workout_offerings

end
