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
#  slug       :string(255)      default(""), not null
#
# Indexes
#
#  index_terms_on_slug             (slug) UNIQUE
#  index_terms_on_year_and_season  (year,season)
#

require 'spec_helper'

describe Term do
  pending "add some examples to (or delete) #{__FILE__}"
end
