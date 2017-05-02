# == Schema Information
#
# Table name: exercise_collections
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  description   :text
#  user_group_id :integer
#  license_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_exercise_collections_on_license_id     (license_id)
#  index_exercise_collections_on_user_group_id  (user_group_id)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :exercise_collection do
    name "MyString"
    description "MyText"
    user_group nil
  end
end
