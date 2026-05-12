class ActivityLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :exercise, optional: true
  belongs_to :workout, optional: true
  belongs_to :workout_offering, optional: true
  belongs_to :workout_score, optional: true
end
