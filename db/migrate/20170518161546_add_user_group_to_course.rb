class AddUserGroupToCourse < ActiveRecord::Migration[5.1]
  def change
    add_reference :courses, :user_group, index: true, foreign_key: true
  end
end
