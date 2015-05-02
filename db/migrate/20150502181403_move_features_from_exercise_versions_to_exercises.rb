class MoveFeaturesFromExerciseVersionsToExercises < ActiveRecord::Migration
  def up
    add_column :exercises, :name, :string
    add_column :exercises, :is_public, :boolean, null: false, default: false
    add_column :exercises, :experience, :integer
    Exercise.all.each do |e|
      e.name = e.current_version.name
      e.is_public = e.current_version.is_public
      e.experience = e.current_version.experience
      e.save
    end
    Exercise.where(experience: nil).each do |e|
      e.experience = 50
      e.save
    end
    change_column_null :exercises, :experience, false
    remove_column :exercise_versions, :name, :string
    remove_column :exercise_versions, :is_public, :boolean
    remove_column :exercise_versions, :experience, :integer
  end

  def down
    add_column :exercise_versions, :name, :string
    add_column :exercise_versions, :is_public, :boolean, null: false,
      default: false
    add_column :exercise_versions, :experience, :integer
    ExerciseVersion.all do |e|
      e.name = e.exercise.name
      e.is_public = e.exercise.is_public
      e.experience = e.exercise.experience
      e.save
    end
    change_column_null :exercise_versions, :experience, false
    remove_column :exercises, :name, :string
    remove_column :exercises, :is_public, :boolean
    remove_column :exercises, :experience, :integer
  end
end
