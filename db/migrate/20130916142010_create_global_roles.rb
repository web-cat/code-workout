class CreateGlobalRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :global_roles do |t|
      t.string :name, :unique => true, :null => false
      t.boolean :can_manage_all_courses, :null => false, :default => false
      t.boolean :can_edit_system_configuration, :null => false, :default => false
      t.boolean :builtin, :null => false, :default => false
    end
  end
end
