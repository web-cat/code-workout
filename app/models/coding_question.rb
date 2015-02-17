class CodingQuestion < ActiveRecord::Base


  #~ Validations
  validates :wrapper_code, presence: true, length: { minimum: 1 }
  validates :test_script, presence: true, length: { minimum: 1 }

  #~ Relationships
  belongs_to :exercise
  has_many :test_cases

  #~ Acceptance
  accepts_nested_attributes_for :test_cases, allow_destroy: true
end
