# == Schema Information
#
# Table name: organizations
#
#  id           :bigint           not null, primary key
#  abbreviation :string(255)
#  is_hidden    :boolean          default(FALSE)
#  name         :string(255)      not null
#  slug         :string(255)      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_organizations_on_name  (name) UNIQUE
#  index_organizations_on_slug  (slug) UNIQUE
#

FactoryBot.define do

  factory :organization do
    name { "Virginia Tech" }
    abbreviation { "VT" }
  end

end
