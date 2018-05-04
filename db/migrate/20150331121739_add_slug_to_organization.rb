class AddSlugToOrganization < ActiveRecord::Migration

  def up
    remove_column :organizations, :url_part, :string
    add_column :organizations, :abbreviation, :string
    add_column :organizations, :slug, :string
    # Force generation of slug values for all entries
    Organization.reset_column_information
    Organization.all.map(&:save)
    change_column_null :organizations, :slug, false
    add_index :organizations, :slug, unique: true
  end

  def down
    # No way to regenerate the url_part content, since the code was
    # removed from the model!
    raise ActiveRecord::IrreversibleMigration
  end

end
