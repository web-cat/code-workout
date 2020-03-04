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

class ExerciseCollection < ActiveRecord::Base
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
