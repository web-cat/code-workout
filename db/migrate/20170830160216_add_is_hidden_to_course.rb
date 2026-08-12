class AddIsHiddenToCourse < ActiveRecord::Migration[5.1]
  def change
    add_column :courses, :is_hidden, :boolean, default: false
  end
end
