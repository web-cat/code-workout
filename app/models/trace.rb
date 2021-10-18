class Trace < ActiveRecord::Base
  belongs_to :answer
  validates :exercise_trace, presence: true
end
