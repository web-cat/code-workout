require 'representable/hash'
class WorkoutRepresenter < Representable::Decorator
  include Representable::Hash

  collection_representer class: Workout


  property :name
  property :scrambled
  property :language_list, getter: lambda { |*| language_list.to_s }
  property :style_list, getter: lambda { |*| style_list.to_s }
  property :tag_list, getter: lambda { |*| tag_list.to_s }
  property :description
  collection :exercise_workouts, as: :exercises, class: ExerciseWorkout do
    property :position
    property :points
    property :exercise, class: Exercise, decorator: ExerciseRepresenter
  end
  collection :workout_offerings, as: :offerings, class: WorkoutOffering do
    property :opening_date
    property :soft_deadline
    property :hard_deadline
    property :course, class: Course,
      getter: lambda { |*| course_offering.course } do
      property :number
      property :organization, class: Organization do
        property :abbreviation
      end
    end
  end

end
