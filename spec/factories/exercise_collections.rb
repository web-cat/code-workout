# == Schema Information
#
# Table name: exercise_collections
#
#  id                 :bigint           not null, primary key
#  description        :text(65535)
#  name               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  course_offering_id :bigint
#  license_id         :bigint
#  user_group_id      :bigint
#  user_id            :bigint
#
# Indexes
#
#  index_exercise_collections_on_course_offering_id  (course_offering_id)
#  index_exercise_collections_on_license_id          (license_id)
#  index_exercise_collections_on_user_group_id       (user_group_id)
#  index_exercise_collections_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (course_offering_id => course_offerings.id)
#  fk_rails_...  (license_id => licenses.id)
#  fk_rails_...  (user_group_id => user_groups.id)
#  fk_rails_...  (user_id => users.id)
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
