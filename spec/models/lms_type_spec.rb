# == Schema Information
#
# Table name: lms_types
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_lms_types_on_name  (name) UNIQUE
#

require 'rails_helper'

RSpec.describe LmsType, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
