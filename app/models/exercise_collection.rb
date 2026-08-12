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

class ExerciseCollection < ApplicationRecord
  belongs_to :user_group, inverse_of: :exercise_collection
  belongs_to :user
  belongs_to :license
  belongs_to :course_offering, inverse_of: :exercise_collections
  has_many :exercises

  def is_public?
    return self.license.andand.license_policy.andand.is_public
  end

  def owned_by?(user)
    if user.nil?
      false
    else
      self.user == user
    end
  end

  def add(*exercises, override: false)
    exercises.flatten.each do |e|
      if e.exercise_collection.nil?
        e.exercise_collection = self
        e.save!
      elsif override
        e.exercise_collection = self
        e.save!
      end
    end
  end
end
