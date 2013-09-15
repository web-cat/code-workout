class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name, null: false

      t.timestamps
    end

    #join table tags<->exercises (many to many)
   	create_table :exercises_tags do |t|
      t.belongs_to :exercise
      t.belongs_to :tag
    end
  end
end
