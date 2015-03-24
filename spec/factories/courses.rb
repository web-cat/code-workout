# == Schema Information
#
# Table name: courses
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  number          :string(255)
#  organization_id :integer
#  url_part        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  creator_id      :integer
#

FactoryGirl.define do

  factory :course do
    name "Introduction to Software Design"
    number "CS 1114"
    organization_id 1
    # url_part "cs-1114"
  end

end
