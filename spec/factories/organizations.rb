# == Schema Information
#
# Table name: organizations
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  abbreviation :string(255)
#  slug         :string(255)      not null
#
# Indexes
#
#  index_organizations_on_slug  (slug) UNIQUE
#

FactoryGirl.define do

  factory :organization do
    display_name "Virginia Tech"
    url_part "vt"
  end

end
