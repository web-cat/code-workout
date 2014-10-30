# == Schema Information
#
# Table name: terms
#
#  id         :integer          not null, primary key
#  season     :integer          not null
#  starts_on  :date             not null
#  ends_on    :date             not null
#  year       :integer          not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_terms_on_starts_on  (starts_on)
#

require 'spec_helper'

describe Term do
  pending "add some examples to (or delete) #{__FILE__}"
end
