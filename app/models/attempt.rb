# == Schema Information
#
# Table name: attempts
#
#  id                  :integer          not null, primary key
#  user_id             :integer          not null
#  exercise_id         :integer          not null
#  submit_time         :datetime         not null
#  submit_num          :integer          not null
#  answer              :text
#  score               :decimal(, )      default(0.0)
#  experience_earned   :integer
#  created_at          :datetime
#  updated_at          :datetime
#  workout_offering_id :integer
#
# Indexes
#
#  index_attempts_on_exercise_id  (exercise_id)
#  index_attempts_on_user_id      (user_id)
#

#table/schema migration for attempt........................
#    create_table :attempts do |t|
#      t.belongs_to :user, index: true, null: false
#      t.belongs_to :exercise, index: true, null: false
#      t.datetime :submit_time, null: false
#      t.integer :submit_num, null: false
#      t.text :answer
#      t.float :score
#      t.integer :experience_earned
#
#      t.timestamps
#    end

class Attempt < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :exercise_version, inverse_of: :attempts
  belongs_to :user, inverse_of: :attempts
  belongs_to :workout_offering, inverse_of: :attempts


  #~ Validation ...............................................................

  validates :user, presence: true
  validates :exercise_version, presence: true
  validates :submit_time, presence: true
  validates :submit_num, numericality: { greater_than: 0 }
  validates :score, numericality: { greater_than_or_equal_to: 0 }


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  # Returns the latest attempt of the given exercise by the given user
  def self.user_attempt(uid, ex_id)
    return Attempt.where(user_id: uid, exercise_id: ex_id).
      where.not(workout_offering_id: nil).andand.last
  end

end
