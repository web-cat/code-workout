class CreateLmsInstances < ActiveRecord::Migration[5.1]
  def change
    create_table :lms_instances do |t|
      t.string :consumer_key
      t.string :consumer_secret

      t.timestamps
    end
  end
end
