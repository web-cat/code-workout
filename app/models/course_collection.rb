class CourseCollection < ExerciseCollection
  has_one :course, through: :user_group
end
