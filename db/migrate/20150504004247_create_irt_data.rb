class CreateIRTData < ActiveRecord::Migration[5.1]
  def change
    create_table :irt_data do |t|
      t.integer  :attempt_count,  null: false
      t.float    :sum_of_scores,  null: false
      t.float    :difficulty,     null: false
      t.float    :discrimination, null: false
    end

    change_table :exercises do |t|
      t.remove :attempt_count
      t.remove :correct_count
      t.remove :difficulty
      t.remove :discrimination

      t.belongs_to :irt_data
      t.foreign_key :irt_data, column: :irt_data_id
    end

    change_table :exercise_versions do |t|
      t.remove :attempt_count
      t.remove :correct_count
      t.remove :difficulty
      t.remove :discrimination

      t.belongs_to :irt_data
      t.foreign_key :irt_data, column: :irt_data_id
    end

    change_table :prompts do |t|
      t.remove :attempt_count
      t.remove :correct_count
      t.remove :difficulty
      t.remove :discrimination

      t.belongs_to :irt_data
      t.foreign_key :irt_data, column: :irt_data_id
    end
  end
end
