class CreateExercises < ActiveRecord::Migration
  def change
  	create_table :exercises do |t|
    	t.belongs_to  :user, index: true, null: false
      t.belongs_to  :stem, index: true
      t.belongs_to  :language, index: true
      #t.has_and_belongs_to_many :tags

      t.string   :title, null: false
      t.text     :question, null: false
      t.text     :feedback
      t.boolean  :is_public, null: false
      t.integer  :priority, null: false
      t.integer  :count_attempts, null: false
      t.float    :count_correct, null: false
      t.float    :difficulty, null: false
      t.float    :discrimination, null: false
      t.integer  :type, null: false

      # MCQ-specific columns, using single-table inheritance:
      t.boolean  :mcq_allow_multiple
      t.boolean  :mcq_is_scrambled

      t.timestamps
    end
  end
end

