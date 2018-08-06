class MakeWorkoutOfferingsPublishedByDefault < ActiveRecord::Migration
  def change
    change_column :workout_offerings, :published, :boolean, default: true
  end
end
