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
  belongs_to :user_group, inverse_of: :exercise_collection # FIXME: This should go after the prod data is refactored into ExerciseCollectionMemberships 
  has_many :exercise_collection_memberships
  has_many :exercises, through: :exercise_collection_memberships
  has_and_belongs_to_many :course_offerings, join_table: 'course_offerings_exercise_collections'

  scope :course_collections, -> { where(type: 'CourseCollection') }
  scope :copyright_owner_collections, -> { where(type: 'CopyrightOwnerCollection') }

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
      # If the exercise isn't already in this exercise collection, add it
      if !e.exercise_collections.exists?(self.id)
        ExerciseCollectionMembership.create(
          exercise_id: e.id,
          exercise_collection_id: self.id
        )
      end
    end
  end
end
