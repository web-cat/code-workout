# == Schema Information
#
# Table name: activity_logs
#
#  id                  :bigint           not null, primary key
#  activity            :string(255)
#  ip_address          :string(255)
#  lti_launch          :boolean          default(FALSE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  exercise_id         :bigint
#  lms_instance_id     :bigint
#  user_id             :bigint
#  workout_id          :bigint
#  workout_offering_id :bigint
#  workout_score_id    :bigint
#
# Indexes
#
#  index_activity_logs_on_exercise_id          (exercise_id)
#  index_activity_logs_on_lms_instance_id      (lms_instance_id)
#  index_activity_logs_on_user_id              (user_id)
#  index_activity_logs_on_workout_id           (workout_id)
#  index_activity_logs_on_workout_offering_id  (workout_offering_id)
#  index_activity_logs_on_workout_score_id     (workout_score_id)
#
# Foreign Keys
#
#  fk_rails_...  (exercise_id => exercises.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (workout_id => workouts.id)
#  fk_rails_...  (workout_offering_id => workout_offerings.id)
#
class ActivityLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :exercise, optional: true
  belongs_to :workout, optional: true
  belongs_to :workout_offering, optional: true
  belongs_to :workout_score, optional: true
end
