class TimeZone < ActiveRecord::Base
  has_many :users
  def to_s
    return display_as
  end
  
  def to_label
    return display_as
  end
end
