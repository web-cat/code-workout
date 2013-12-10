class TestCase < ActiveRecord::Base
  #~ Relationships ............................................................

  belongs_to :exercise

  #~ Hooks ....................................................................

  #~ Validation ...............................................................

  validates :testscript, presence: true, length: {minimum: 1}
  #validates :feedback
  
  #~ Private instance methods .................................................
end
