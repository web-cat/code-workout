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

  belongs_to :exercise, inverse_of: :attempts
  belongs_to :user, inverse_of: :attempts
  belongs_to :workout_offering, inverse_of: :attempts


  #~ Validation ...............................................................

  validates :user, presence: true
  validates :exercise, presence: true
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


  # -------------------------------------------------------------
  # Returns the user's score for a particular workout by combing through
  # attempts
  # TODO: why is this even a method in this class?  Shouldn't this
  # behavior come from the Workout class?
  def self.get_workout_score(uid, wktid)
    # TODO: this is completely broken, since it assumes attempts in one
    # workout are stored sequentially and contiguously, which is wrong.
    wkt_len = Workout.find(wktid).exercises.length
    relevant_workout_offerings = WorkoutOffering.where(workout_id: wktid).to_a
    workouts_offering_ids = Array.new
    relevant_workout_offerings.each do |wkt|
      workouts_offering_ids << wkt.id
    end
    user_attempts = Attempt.where(user_id: uid,
      workout_offering_id: workouts_offering_ids)
    user_attempts_array = user_attempts.to_a
    user_end = user_attempts_array.last.id
    puts "GOSHIEN user end"
    puts user_end
    puts "Ghoshien"
    user_wkt_attempts = Attempt.where("id <= ? and id > ?",
      user_end, user_end - wkt_len).to_a
    final_score = 0
    user_wkt_attempts.each do |attempt|
      final_score += attempt.score
    end
    return final_score
  end

end
