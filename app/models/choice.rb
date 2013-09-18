class Choice < ActiveRecord::Base
  #~ Relationships ............................................................

  belongs_to :exercise

  #~ Hooks ....................................................................

  #~ Validation ...............................................................

  validates :answer, presence: true, length: {minimum: 1}
  validates :order, presence: true, numericality: true
  validates :value, presence: true, numericality: true
  
  #~ Private instance methods .................................................
end
