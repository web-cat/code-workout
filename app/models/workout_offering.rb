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
  belongs_to :workout
  belongs_to :course_offering
end
