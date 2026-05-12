# == Schema Information
#
# Table name: workout_owners
#
#  id         :bigint           not null, primary key
#  owner_id   :bigint           not null
#  workout_id :bigint           not null
#
# Indexes
#
#  index_workout_owners_on_workout_id               (workout_id)
#  index_workout_owners_on_workout_id_and_owner_id  (workout_id,owner_id) UNIQUE
#  workout_owners_owner_id_fk                       (owner_id)
#
# Foreign Keys
#
#  fk_rails_...                  (owner_id => users.id)
#  fk_rails_...                  (workout_id => workouts.id)
#  workout_owners_owner_id_fk    (owner_id => users.id)
#  workout_owners_workout_id_fk  (workout_id => workouts.id)
#

# =============================================================================
# Represents a many-to-many relationship between workouts and users,
# indicating which users "own" an exercise.  This is primarily for the
# purpose of managing editing access to workouts, particularly "private"
# workouts that are not publicly available in the gym.
#
class WorkoutOwner < ApplicationRecord

  #~ Relationships ............................................................

  belongs_to :workout, inverse_of: :workout_owners
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id',
    inverse_of: :workout_owners


  #~ Validation ...............................................................

  validates :workout, presence: true
  validates :owner, presence: true

end
