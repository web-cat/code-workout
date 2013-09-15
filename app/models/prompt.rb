class Prompt < ActiveRecord::Base
  #~ Relationships ............................................................

  #TODO define Attempt model and relate to prompt for each student attempt
  belongs_to :exercise
  has_and_belongs_to_many :tags
  #TODO define Hint model and decide how a hint determines how it maps to 
  # different types of incorrect attempts
  has_many :choices
  belongs_to :prompt_type
  belongs_to :language
  belongs_to :question

  #~ Hooks ....................................................................

  #~ Validation ...............................................................

  validates :question, presence: true
  validates :instruction, presence: true
  validates :order, presence: true, numericality: true
  validates :max_attempts, numericality: true
  #no validation for feedback
  validates :difficulty, presence: true, numericality: true
  validates :discrimination, presence: true, numericality: true
  validates :prompt_type, presence: true, numericality: true
  #no validation for single table inheritance of MCQ columns: 
  # allow_multiple, is_scrambled

  #~ Class methods.............................................................

  #~ Instance methods .................................................
  #TODO methods for calculating score and correctness
end