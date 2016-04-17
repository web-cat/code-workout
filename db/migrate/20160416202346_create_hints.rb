class CreateHints < ActiveRecord::Migration
  def change
    create_table :hints do |t|
      t.integer :exercise_version_id
      t.integer :user_id
      t.string :body
      t.boolean :curated

      t.timestamps
      t.belongs_to :user, index: :true
      t.belongs_to :exercise_version, index: :true
    end
  end
end
