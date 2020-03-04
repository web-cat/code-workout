# == Schema Information
#
# Table name: exercise_collections
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  description        :text(65535)
#  user_group_id      :integer
#  license_id         :integer
#  created_at         :datetime
#  updated_at         :datetime
#  user_id            :integer
#  course_offering_id :integer
#
# Indexes
#
#  index_exercise_collections_on_course_offering_id  (course_offering_id)
#  index_exercise_collections_on_license_id          (license_id)
#  index_exercise_collections_on_user_group_id       (user_group_id)
#  index_exercise_collections_on_user_id             (user_id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :exercise_collection do
    factory :group_owned_collection do
      name { "MCQExercises" }
      description { "Collection of multiple choice exercises." \
        "Created by FactoryBot for testing." }
    end
    factory :user_owned_collection do
      name { "Owned by user" }
      description { "Exercises owned by a single user." }
    end
  end
end
