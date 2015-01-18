# == Schema Information
#
# Table name: attempts
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  exercise_id       :integer          not null
#  submit_time       :datetime         not null
#  submit_num        :integer          not null
#  answer            :text
#  score             :float
#  experience_earned :integer
#  created_at        :datetime
#  updated_at        :datetime
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
  
  belongs_to :exercise

  #TODO tie attempt to current user session
  #validates :user, presence: true
  #belongs_to :user
  validates :exercise, presence: true
  
  # Returns whether an user has attempted an exercise or not, if attempted returns the latest score
  def self.user_attempt(uid,ex_id)
    last_attempt=Attempt.where(user_id: uid, exercise_id: ex_id).where.not(workout_offering_id: nil).last
    if last_attempt.nil?
      return false
    else
      return last_attempt.score
    end
  end
  
  # Returns the user's score for a particular worked by combing through attempts
  def self.getUserScore(uid,wktid)
    wkt_len=Workout.find(wktid).exercises.length;
    relevant_workout_offerings=WorkoutOffering.where(workout_id: wktid).to_a
    workouts_offering_ids=Array.new
    relevant_workout_offerings.each do |wkt|
      workouts_offering_ids<<wkt.id
    end
    user_attempts=Attempt.where(user_id: uid,workout_offering_id: workouts_offering_ids);
    user_attempts_array=user_attempts.to_a
    user_end = user_attempts_array.last.id;
    puts "GOSHIEN user end"
    puts user_end
    puts "Ghoshien"
    user_wkt_attempts=Attempt.where("id<=? and id>?",user_end,user_end-wkt_len ).to_a;
    final_score=0
    user_wkt_attempts.each do |attempt|
      final_score+=attempt.score
    end
    return final_score
  end
  
end
