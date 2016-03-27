class CreateResponses < ActiveRecord::Migration
  def up
    create_table :responses do |t|
        t.string :text
        t.integer :user_id
        t.integer :question_id
        t.timestamps
    end

    add_foreign_key :responses, :users
    add_foreign_key :responses, :questions
  end

  def down
    remove_table :responses
  end
end
