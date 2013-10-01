class CreateExperienceColumn < ActiveRecord::Migration
  def change
    add_column :exercises, :experience, :integer
  end
end
