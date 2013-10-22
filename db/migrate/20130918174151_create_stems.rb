class CreateStems < ActiveRecord::Migration
  def change
    create_table :stems do |t|
      t.text :preamble

      t.timestamps
    end
  end
end
