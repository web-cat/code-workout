class CreateQuestions < ActiveRecord::Migration
  def up
    create_table :questions do |t|
        t.string :title
        t.string :body
        t.string :tags
        t.integer :user_id
        t.integer :exercise_id
        t.timestamps
    end
    add_foreign_key :questions, :users
    add_foreign_key :questions, :exercises

   end

  def down
    drop_table :questions
  end
end
