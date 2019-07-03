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
#  user_group_id   :integer
#  is_hidden       :boolean          default(FALSE)
#
# Indexes
#
#  index_courses_on_organization_id  (organization_id)
#  index_courses_on_slug             (slug)
#  index_courses_on_user_group_id    (user_group_id)
#

FactoryBot.define do

  factory :course do
    name { "Introduction to Software Design" }
    number { "CS 1114" }
    organization_id { 1 }
    # url_part "cs-1114"
  end

  factory :cs_3114 do
    name { 'Data Structures and Algorithms' }
    number { 'CS 3114' }
    organization_id { 1 }
  end
end
