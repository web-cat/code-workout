# == Schema Information
#
# Table name: variation_groups
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class VariationGroup < ActiveRecord::Base
  #Relationships
  has_many :base_exercises
  
  #Validations
  validates :title, presence: true
end
