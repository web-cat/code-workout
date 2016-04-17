class Hint < ActiveRecord::Base
  belongs_to :user
  belongs_to :exercise_version
  
  validates :user, presence: true
  validates :exercise_version, presence: true
  validates :body, presence: true
end
