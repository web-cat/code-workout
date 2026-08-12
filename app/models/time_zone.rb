# == Schema Information
#
# Table name: time_zones
#
#  id         :bigint           not null, primary key
#  display_as :string(255)
#  name       :string(255)
#  zone       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TimeZone < ApplicationRecord
  has_many :users
  def to_s
    return display_as
  end
  
  def to_label
    return display_as
  end
end
