# == Schema Information
#
# Table name: time_zones
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  zone       :string(255)
#  display_as :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class TimeZone < ActiveRecord::Base
  has_many :users
  def to_s
    return display_as
  end
  
  def to_label
    return display_as
  end
end
