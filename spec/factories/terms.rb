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

FactoryGirl.define do

  factory :term do
    season 100
    starts_on "2013-01-15"
    ends_on "2013-05-15"
    year 2013

    factory :term2 do
      season 400
      starts_on "2013-08-15"
      ends_on "2013-12-15"
    end
  end

end
