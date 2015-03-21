class AddCreatorIdToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :creator_id, :integer
  end
end
