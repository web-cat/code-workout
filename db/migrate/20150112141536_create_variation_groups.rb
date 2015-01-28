class CreateVariationGroups < ActiveRecord::Migration
  def change
    create_table :variation_groups do |t|
      t.string :title

      t.timestamps
    end
  end
end
