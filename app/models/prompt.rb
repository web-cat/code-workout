class Prompt < ActiveRecord::Base
  #~ Relationships ............................................................

  #TODO define Attempt model and relate to prompt for each student attempt
  belongs_to :exercise
  #TODO define Hint model and decide how a hint determines how it maps to 
  # different types of incorrect attempts
  has_one :prompt_type
  has_one :language

  #~ Hooks ....................................................................

  #~ Validation ...............................................................
  validates :exercise_id, presence: true, numericality: true
  validates :prompt_type_id, presence: true, numericality: true
  validates :language_id, numericality: true
  
  
  validates :instruction, presence: true
  validates :order, presence: true, numericality: true
  validates :max_attempts, numericality: true
  validates :attempts, numericality: true, presence: true
  validates :correct, numericality: true, presence: true
  #no validation for feedback
  validates :difficulty, presence: true, numericality: true
  validates :discrimination, presence: true, numericality: true

  #~ Class methods.............................................................

  #~ Instance methods .................................................
  #TODO methods for calculating score and correctness
end