class CopyrightOwnerCollection < ExerciseCollection
  belongs_to :owner, class_name: 'User', foreign_key: 'user_id', inverse_of: :exercise_collection
  belongs_to :license
end
