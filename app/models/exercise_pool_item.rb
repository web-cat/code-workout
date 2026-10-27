class ExercisePoolItem < ApplicationRecord

  #~ Relationships ............................................................

  belongs_to :exercise_pool, inverse_of: :exercise_pool_items
  belongs_to :exercise, inverse_of: :exercise_pool_items
  acts_as_list scope: :exercise_pool


  #~ Validation ...............................................................

  validates :exercise_pool, presence: true
  validates :exercise, presence: true
  validates :exercise_id, uniqueness: { scope: :exercise_pool_id, message: 'is already in this exercise pool' }

end
