# == Schema Information
#
# Table name: exercise_owners
#
#  id          :integer          not null, primary key
#  exercise_id :integer          not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_exercise_owners_on_exercise_id_and_user_id  (exercise_id,user_id) UNIQUE
#

class ExerciseOwner < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :exercise, inverse_of: :exercise_owners
  belongs_to :user, inverse_of: :exercise_owners


  #~ Validation ...............................................................

  validates :exercise, presence: true
  validates :user, presence: true

end
