class CreateTerms < ActiveRecord::Migration[5.1]
  def change
    create_table :terms do |t|
      t.integer :season, null: false
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.integer :year, null: false

      t.timestamps
    end

    add_index :terms, :starts_on
  end
end
