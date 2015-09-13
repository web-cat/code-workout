class TimeZone < ActiveRecord::Base
  has_many :users
  def to_s
    return display_as
  end
end
