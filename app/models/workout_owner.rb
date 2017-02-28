# == Schema Information
#
# Table name: workout_owners
#
#  id         :integer          not null, primary key
#  workout_id :integer          not null
#  owner_id   :integer          not null
#
# Indexes
#
#  index_workout_owners_on_workout_id_and_owner_id  (workout_id,owner_id) UNIQUE
#  workout_owners_owner_id_fk                       (owner_id)
#

# =============================================================================
# Represents a many-to-many relationship between workouts and users,
# indicating which users "own" an exercise.  This is primarily for the
# purpose of managing editing access to workouts, particularly "private"
# workouts that are not publicly available in the gym.
#
class WorkoutOwner < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :workout, inverse_of: :workout_owners
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id',
    inverse_of: :workout_owners


  #~ Validation ...............................................................

  validates :workout, presence: true
  validates :owner, presence: true

end
