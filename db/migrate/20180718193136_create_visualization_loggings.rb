class CreateVisualizationLoggings < ActiveRecord::Migration
  def change
    create_table :visualization_loggings do |t|
      t.references :user, index: true
      t.references :exercise, index: true
      t.references :workout, index: true
      t.references :workout_offering, index: true

      t.timestamps
    end
  end
end
