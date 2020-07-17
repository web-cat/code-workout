class CourseCollection < ExerciseCollection
  has_one :course, through: :user_group
  belongs_to :course_offering, inverse_of: :exercise_collections
end
