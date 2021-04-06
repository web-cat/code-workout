class Answer < ApplicationRecord
  belongs_to :popexercise
  has_one :trace
end
