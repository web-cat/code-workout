class ChangeClassNameToStringInErrors < ActiveRecord::Migration
  def change
    change_column :errors, :class_name, :string
  end
end
