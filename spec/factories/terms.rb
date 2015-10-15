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

FactoryGirl.define do

  factory :term do
    season 100
    starts_on "2015-01-15"
    ends_on "2015-05-15"
    year 2015

    factory :term2 do
      season 400
      starts_on "2014-08-15"
      ends_on "2014-12-15"
      year 2014
    end

    factory :term3 do
      season 200
      starts_on "2013-05-15"
      ends_on "2013-06-30"
      year 2013
    end
  end

end
