# == Schema Information
#
# Table name: workout_scores
#
#  id                  :integer          not null, primary key
#  workout_id          :integer          not null
#  user_id             :integer          not null
#  score               :float
#  completed           :boolean
#  completed_at        :datetime
#  last_attempted_at   :datetime
#  exercises_completed :integer
#  exercises_remaining :integer
#  created_at          :datetime
#  updated_at          :datetime
#
# Indexes
#
#  index_workout_scores_on_user_id     (user_id)
#  index_workout_scores_on_workout_id  (workout_id)
#

class WorkoutScore < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :workout, inverse_of: :workout_scores
  belongs_to :user, inverse_of: :workout_scores


  #~ Validation ...............................................................

  validates :workout, presence: true
  validates :user, presence: true

end
