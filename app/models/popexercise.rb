class Popexercise < ActiveRecord::Base
    has_many :answers

    validates :exercise_id, presence: true
    validates :code, presence: true
end
