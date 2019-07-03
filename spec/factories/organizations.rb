# == Schema Information
#
# Table name: organizations
#
#  id           :integer          not null, primary key
#  name         :string(255)      default(""), not null
#  created_at   :datetime
#  updated_at   :datetime
#  abbreviation :string(255)
#  slug         :string(255)      default(""), not null
#  is_hidden    :boolean          default(FALSE)
#
# Indexes
#
#  index_organizations_on_slug  (slug) UNIQUE
#

FactoryBot.define do

  factory :organization do
    name { "Virginia Tech" }
    abbreviation { "VT" }
  end

end
