class Answer < ActiveRecord::Base
  belongs_to :popexercise
  has_one :trace
end
