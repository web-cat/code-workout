# == Schema Information
#
# Table name: base_exercises
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  question_type      :integer
#  current_version    :integer
#  created_at         :datetime
#  updated_at         :datetime
#  versions           :integer
#  variation_group_id :integer
#

class BaseExercise < ActiveRecord::Base
  #Relationships
  has_many :exercises
  belongs_to :validation_group
  #Hooks
  before_validation :set_defaults
  
  #Validations
  validates :current_version, presence: true, numericality: true
  
  TYPES = {
    'Multiple Choice Question' => 1,
    'Coding Question' => 2,
    'Fill in the blanks' => 3
  }
  
  def type_name
    BaseExercise.type_name(self.question_type)
  end
  
  private
  def set_defaults
    self.question_type ||= TYPES['Multiple Choice Question']
  end
   
end
