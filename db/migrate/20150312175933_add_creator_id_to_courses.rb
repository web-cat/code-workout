class AddCreatorIdToCourses < ActiveRecord::Migration[5.1]
  def change
    add_column :courses, :creator_id, :integer
  end
end
