class AddUserGroupToCourse < ActiveRecord::Migration
  def change
    add_reference :courses, :user_group, index: true, foreign_key: true
  end
end
