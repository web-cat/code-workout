class CreateTotalExerciseAndTotalExperienceInTag < ActiveRecord::Migration[5.1]
  def change
  	add_column :tags, :total_exercises, :integer, :default => 0
  	add_column :tags, :total_experience, :integer, :default => 0
  end
end
