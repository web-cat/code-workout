# == Schema Information
#
# Table name: prompts
#
#  id                :integer          not null, primary key
#  exercise_id       :integer          not null
#  language_id       :integer          not null
#  instruction       :text             not null
#  order             :integer          not null
#  max_user_attempts :integer
#  attempts          :integer
#  correct           :float
#  feedback          :text
#  difficulty        :float            not null
#  discrimination    :float            not null
#  type              :integer          not null
#  allow_multiple    :boolean
#  is_scrambled      :boolean
#  created_at        :datetime
#  updated_at        :datetime
#

class Prompt < ActiveRecord::Base
  #~ Relationships ............................................................

  #TODO define Attempt model and relate to prompt for each student attempt
  belongs_to :exercise
  #TODO define Hint model and decide how a hint determines how it maps to 
  # different types of incorrect attempts
  has_one :prompt_type
  has_one :language
  has_many :choices

  # Hard-coded prompt types. Add others as functionality extends to
  #  support other prompt types (free response, etc)
  TYPES = {
    'Multiple Choice' => 1
  }


  #~ Hooks ....................................................................

  #~ Validation ...............................................................
  validates :exercise_id, presence: true, numericality: true
  validates :language_id, numericality: true
  
  validates :instruction, presence: true
  validates :order, presence: true, numericality: true
  validates :max_user_attempts, numericality: true
  validates :attempts, numericality: true, presence: true
  validates :correct, numericality: true, presence: true
  #no validation for feedback
  validates :difficulty, presence: true, numericality: true
  validates :discrimination, presence: true, numericality: true
  validates :type, presence: true, numericality: true



  #~ Class methods.............................................................
  
  # -------------------------------------------------------------
  def self.type_name(type)
    TYPES.rassoc(type).first
  end

  #~ Instance methods .........................................................
  #TODO methods for calculating scores, difficulty, and discrimination
end
