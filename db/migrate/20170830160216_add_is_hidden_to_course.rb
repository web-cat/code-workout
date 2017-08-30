class AddIsHiddenToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :is_hidden, :boolean, default: false
  end
end
