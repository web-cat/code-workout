class Trace < ApplicationRecord
  belongs_to :answer
  validates :exercise_trace, presence: true
end
