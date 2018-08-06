class CreateTimeZones < ActiveRecord::Migration
  def change
    create_table :time_zones do |t|
      t.string :name
      t.string :zone
      t.string :display_as

      t.timestamps
    end
  end
end
