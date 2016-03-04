class Question < ActiveRecord::Base
    has_many :responses
    belongs_to :user
    belongs_to :exercise
end
