class CreateTagUserScores < ActiveRecord::Migration
  def change
    create_table :tag_user_scores do |t|
      t.belongs_to  :user, index: true, null: false
      t.belongs_to  :tag, index: true, null: false
      t.integer		:experience, index: true, default: 0
      t.timestamps
    end
  end
end
