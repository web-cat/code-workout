# == Schema Information
#
# Table name: prompts
#
#  id                :integer          not null, primary key
#  exercise_id       :integer          not null
#  language_id       :integer          not null
#  instruction       :text             not null
#  order             :integer          not null
#  max_user_attempts :integer          not null
#  attempts          :integer          not null
#  correct           :float            not null
#  feedback          :text
#  difficulty        :float            not null
#  discrimination    :float            not null
#  type              :integer          not null
#  allow_multiple    :boolean
#  is_scrambled      :boolean
#  created_at        :datetime
#  updated_at        :datetime
#
# Indexes
#
#  index_prompts_on_exercise_id  (exercise_id)
#  index_prompts_on_language_id  (language_id)
#

class Prompt < ActiveRecord::Base

  #~ Relationships ............................................................

  # TODO: define Attempt model and relate to prompt for each student attempt
  belongs_to :exercise_version, inverse_of: :prompts
  # TODO: define Hint model and decide how a hint determines how it maps to
  # different types of incorrect attempts
  has_many :choices

  # has_one :prompt_type
  # has_one :language


  #~ Hooks ....................................................................


  #~ Validation ...............................................................

  validates :exercise_version, presence: true
  validates :language_id, numericality: true

  validates :instruction, presence: true
  validates :order, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :max_user_attempts,
    numericality: { greater_than_or_equal_to: 0 }
  validates :attempts, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :correct, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  #no validation for feedback
  validates :difficulty, presence: true, numericality: true
  validates :discrimination, presence: true, numericality: true
  validates :type, presence: true



  #~ Class methods.............................................................

  #~ Instance methods .........................................................

  #TODO methods for calculating scores, difficulty, and discrimination

end
