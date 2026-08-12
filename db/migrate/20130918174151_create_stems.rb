class CreateStems < ActiveRecord::Migration[5.1]
  def change
    create_table :stems do |t|
      t.text :preamble

      t.timestamps
    end
  end
end
