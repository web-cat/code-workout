# == Schema Information
#
# Table name: terms
#
#  id         :bigint           not null, primary key
#  ends_on    :date             not null
#  season     :integer          not null
#  slug       :string(255)      not null
#  starts_on  :date             not null
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_terms_on_slug             (slug) UNIQUE
#  index_terms_on_starts_on        (starts_on)
#  index_terms_on_year_and_season  (year,season)
#

FactoryBot.define do

  factory :term do
    year { Date.today.year } 

    factory :term100 do
      season { 100 }
      starts_on { "#{Date.today.year}-01-01" }
      ends_on { "#{Date.today.year}-05-31" }
    end

    factory :term200 do
      season { 200 }
      starts_on { "#{Date.today.year}-06-01" }
      ends_on { "#{Date.today.year}-07-15" }
    end

    factory :term300 do
      season { 300 }
      starts_on { "#{Date.today.year}-07-16" }
      ends_on { "#{Date.today.year}-08-15" }
    end

    factory :term400 do
      season { 400 }
      starts_on { "#{Date.today.year}-08-16" }
      ends_on { "#{Date.today.year}-12-15" }
    end

    factory :term500 do
      season { 500 }
      starts_on { "#{Date.today.year}-12-16" }
      ends_on { "#{Date.today.year}-12-31" }
    end
  end
end
