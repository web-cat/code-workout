class CreateResourceFiles < ActiveRecord::Migration
  def change
    create_table :resource_files do |t|
      t.column :filename, :string
      t.column :token, :string
      t.belongs_to :user
      t.column :public, :boolean, default: true
      t.timestamps
    end

    #has and belongs to many exercises
    create_join_table :exercises, :resource_files
  end
end