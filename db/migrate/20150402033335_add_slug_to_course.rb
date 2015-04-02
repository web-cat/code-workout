class AddSlugToCourse < ActiveRecord::Migration

  def up
    remove_index :courses, :url_part
    remove_column :courses, :url_part, :string
    add_column :courses, :slug, :string
    # Force generation of slug values for all entries
    Course.reset_column_information
    Course.all.map(&:save)
    change_column_null :courses, :slug, false
    add_index :courses, :slug
  end

  def down
    # No way to regenerate the url_part content, since the code was
    # removed from the model!
    raise ActiveRecord::IrreversibleMigration
  end

end
