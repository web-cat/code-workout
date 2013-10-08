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
