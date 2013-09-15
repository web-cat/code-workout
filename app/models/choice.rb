class Choice < ActiveRecord::Base
  #~ Relationships ............................................................

  belongs_to :prompt

  #~ Hooks ....................................................................

  #~ Validation ...............................................................

  validates :prompt, presence: true, numericality: true
  validates :answer, presence: true, length: {minimum: 1}
  validates :order, presence: true, numericality: true
  validates :value, presence: true, numericality: true
  
  #~ Private instance methods .................................................
end
