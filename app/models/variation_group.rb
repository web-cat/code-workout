class VariationGroup < ActiveRecord::Base
  #Relationships
  has_many :base_exercises
  
  #Validations
  validates :title, presence: true
end
