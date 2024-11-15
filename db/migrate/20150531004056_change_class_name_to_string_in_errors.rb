class ChangeClassNameToStringInErrors < ActiveRecord::Migration[5.1]
  def change
    change_column :errors, :class_name, :string
  end
end
