class AddSlugToTerm < ActiveRecord::Migration
  def up
    add_column :terms, :slug, :string
    # Force generation of slug values for all entries
    Term.all.map(&:save)
    change_column_null :terms, :slug, false
    add_index :terms, :slug, unique: true
  end

  def down
    remove_index :terms, :slug
    remove_column :terms, :slug, :string
  end
end
