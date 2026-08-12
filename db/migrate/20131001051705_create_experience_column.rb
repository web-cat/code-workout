class CreateExperienceColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :exercises, :experience, :integer
  end
end
