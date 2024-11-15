class MakeWorkoutOfferingsPublishedByDefault < ActiveRecord::Migration[5.1]
  def change
    change_column :workout_offerings, :published, :boolean, default: true
  end
end
