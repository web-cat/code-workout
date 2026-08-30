# == Schema Information
#
# Table name: courses
#
#  id              :bigint           not null, primary key
#  is_hidden       :boolean          default(FALSE)
#  name            :string(255)      not null
#  number          :string(255)      not null
#  slug            :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_id      :integer
#  organization_id :bigint           not null
#  user_group_id   :bigint
#
# Indexes
#
#  index_courses_on_organization_id  (organization_id)
#  index_courses_on_slug             (slug)
#  index_courses_on_user_group_id    (user_group_id)
#
# Foreign Keys
#
#  courses_organization_id_fk  (organization_id => organizations.id)
#  fk_rails_...                (organization_id => organizations.id)
#  fk_rails_...                (user_group_id => user_groups.id)
#

FactoryBot.define do

  factory :course do
    name { "Introduction to Software Design" }
    number { "CS 1114" }
    organization
  end

  factory :cs_3114, class: 'Course' do
    name { 'Data Structures and Algorithms' }
    number { 'CS 3114' }
    organization
  end
end
