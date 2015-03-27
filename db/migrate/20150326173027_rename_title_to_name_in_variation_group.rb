class RenameTitleToNameInVariationGroup < ActiveRecord::Migration
  def change
    rename_column :variation_groups, :title, :name
  end
end
