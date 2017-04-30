# == Schema Information
#
# Table name: courses
#
#  id              :integer          not null, primary key
#  name            :string(255)      default(""), not null
#  number          :string(255)      default(""), not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#  creator_id      :integer
#  slug            :string(255)      default(""), not null
#
# Indexes
#
#  index_courses_on_organization_id  (organization_id)
#  index_courses_on_slug             (slug)
#

FactoryGirl.define do

  factory :course do
    name "Introduction to Software Design"
    number "CS 1114"
    organization_id 1
    # url_part "cs-1114"
  end

end
