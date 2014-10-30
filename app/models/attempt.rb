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

  #TO DO tie attempt to current user session
  #validates :user, presence: true
  #belongs_to :user
  validates :exercise, presence: true
  
end
