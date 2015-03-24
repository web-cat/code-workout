collection @workouts

attributes :name, :scrambled, :description, :target_group, :points_multiplier

child(:exercise_workouts => :exercises) do
  attribute :exercise_id => :exid
  attributes :ordering, :points
end

child(:workout_scores => :scores) do
  node(:user) { |s| s.user.email }
  attributes :score, :completed, :completed_at, :last_attempted_at,
    :exercises_completed, :exercises_remaining
end

node :tags do |workout|
  if workout.tags.size > 0
    workout.tags.map {|t| t.tag_name}.join(', ')
  end
end

child(:workout_offerings => :offerings) do
  child :course_offering => :course do
    node(:organization) { |c| c.course.andand.organization.display_name }
    node(:name) { |c| c.course.name }
  end
  attributes :opening_date, :soft_deadline, :hard_deadline
end
