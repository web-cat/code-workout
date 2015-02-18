# == Schema Information
#
# Table name: organizations
#
#  id           :integer          not null, primary key
#  display_name :string(255)
#  url_part     :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

FactoryGirl.define do

  factory :organization do
    display_name "Virginia Tech"
    url_part "vt"
  end

end
