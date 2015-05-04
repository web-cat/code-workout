class CreateIRTData < ActiveRecord::Migration
  def change
    create_table :irt_data do |t|
      t.integer  :attempt_count,  null: false
      t.float    :sum_of_scores,  null: false
      t.float    :difficulty,     null: false
      t.float    :discrimination, null: false
    end

    change_table :exercises do |t|
      t.remove :attempt_count, :integer
      t.remove :correct_count, :float
      t.remove :difficulty, :float
      t.remove :discrimination, :float

      t.belongs_to :irt_data
      t.foreign_key :irt_datas
    end

    change_table :exercise_versions do |t|
      t.remove :attempt_count, :integer
      t.remove :correct_count, :float
      t.remove :difficulty, :float
      t.remove :discrimination, :float

      t.belongs_to :irt_data
      t.foreign_key :irt_datas
    end

    change_table :prompts do |t|
      t.remove :attempt_count, :integer
      t.remove :correct_count, :float
      t.remove :difficulty, :float
      t.remove :discrimination, :float

      t.belongs_to :irt_data
      t.foreign_key :irt_datas
    end
  end
end
