class AddSlugToUser < ActiveRecord::Migration

  def up
    add_column :users, :slug, :string
    # Force generation of slug values for all entries
    User.reset_column_information
    User.all.map(&:save)
    change_column_null :users, :slug, false
    add_index :users, :slug, unique: true
  end

  def down
    remove_index :users, :slug
    remove_column :users, :slug, :string
  end

end
