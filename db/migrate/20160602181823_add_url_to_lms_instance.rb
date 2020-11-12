class AddUrlToLmsInstance < ActiveRecord::Migration[5.1]
  def change
    add_column :lms_instances, :url, :string
    
    add_index :lms_instances, :url, unique: true
  end
end
