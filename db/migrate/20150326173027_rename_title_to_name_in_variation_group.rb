class RenameTitleToNameInVariationGroup < ActiveRecord::Migration[5.1]
  def change
    rename_column :variation_groups, :title, :name
  end
end
