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
