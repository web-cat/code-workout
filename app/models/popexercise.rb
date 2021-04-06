class Popexercise < ApplicationRecord
    has_many :answers

    validates :exercise_id, presence: true
    validates :code, presence: true
end
