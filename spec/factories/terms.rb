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
    year 2016

    factory :term100 do
      season 100
      starts_on "2016-01-01"
      ends_on "2016-05-31"
    end

    factory :term200 do
      season 200
      starts_on "2016-06-01"
      ends_on "2016-07-15"
    end

    factory :term300 do
      season 300
      starts_on "2016-07-16"
      ends_on "2016-08-15"
    end

    factory :term400 do
      season 400
      starts_on "2016-08-16"
      ends_on "2016-12-15"
    end

    factory :term500 do
      season 500
      starts_on "2016-12-16"
      ends_on "2016-12-31"
    end
  end
end
