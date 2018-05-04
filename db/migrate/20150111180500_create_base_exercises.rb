class CreateBaseExercises < ActiveRecord::Migration
  def change
    create_table :base_exercises do |t|
      t.integer :user_id
      t.integer :question_type
      t.integer :current_version

      t.timestamps
    end
  end
end
