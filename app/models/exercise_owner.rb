# == Schema Information
#
# Table name: exercise_owners
#
#  id          :integer          not null, primary key
#  exercise_id :integer          not null
#  owner_id    :integer          not null
#
# Indexes
#
#  exercise_owners_owner_id_fk                        (owner_id)
#  index_exercise_owners_on_exercise_id_and_owner_id  (exercise_id,owner_id) UNIQUE
#

# =============================================================================
# Represents a many-to-many relationship between exercises and users,
# indicating which users "own" an exercise.  This is primarily for the
# purpose of managing editing access to exercises, particularly "private"
# exercises that are not publicly available in the gym.
#
class ExerciseOwner < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :exercise, inverse_of: :exercise_owners
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id',
    inverse_of: :exercise_owners


  #~ Validation ...............................................................

  validates :exercise, presence: true
  validates :owner, presence: true

end
