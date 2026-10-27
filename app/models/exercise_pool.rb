class ExercisePool < ApplicationRecord

  #~ Relationships ............................................................

  belongs_to :workout, inverse_of: :exercise_pools
  has_many :exercise_pool_items,
    -> { order('exercise_pool_items.position ASC') },
    inverse_of: :exercise_pool,
    dependent: :destroy
  has_many :exercises, through: :exercise_pool_items
  has_many :workout_score_exercises, dependent: :nullify

  acts_as_list scope: :workout

  accepts_nested_attributes_for :exercise_pool_items, allow_destroy: true


  #~ Validation ...............................................................

  validates :workout, presence: true
  validates :select_count, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :points, numericality: { greater_than_or_equal_to: 0 }


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  # True if this slot represents a single fixed exercise (k = 1, N <= 1)
  def single_exercise?
    select_count == 1 && exercises.size <= 1
  end


  # -------------------------------------------------------------
  # Total points for this pool slot (k * points_per_exercise)
  def total_points
    (select_count || 1) * (points || 0.0)
  end

end
