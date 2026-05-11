class CreateActivityLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_logs do |t|
      t.references :user, foreign_key: true
      t.references :exercise, foreign_key: true
      t.references :workout, foreign_key: true
      t.references :workout_offering, foreign_key: true
      t.string :activity
      t.string :ip_address

      t.timestamps
    end
  end
end
