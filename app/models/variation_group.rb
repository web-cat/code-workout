# == Schema Information
#
# Table name: variation_groups
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class VariationGroup < ActiveRecord::Base

  #~ Relationships ............................................................

  has_many :base_exercises, inverse_of: :variation_group, dependent: :nullify


  #~ Validation ...............................................................

  validates :name, presence: true

end
