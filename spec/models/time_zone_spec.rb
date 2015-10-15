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

require 'rails_helper'

RSpec.describe TimeZone, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
