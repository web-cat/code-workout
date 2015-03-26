# == Schema Information
#
# Table name: organizations
#
#  id           :integer          not null, primary key
#  display_name :string(255)      not null
#  url_part     :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_organizations_on_url_part  (url_part)
#

FactoryGirl.define do

  factory :organization do
    display_name "Virginia Tech"
    url_part "vt"
  end

end
