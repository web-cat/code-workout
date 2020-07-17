class CourseCollection < ExerciseCollection
  has_one :course, through: :user_group
  has_and_belongs_to_many :course_offerings, foreign_key: 'exercise_collection_id', join_table: 'course_offerings_exercise_collections'
end
