class UpdateExercise < ActiveRecord::Migration
  def change
  	#allow empty titles in database
  	change_column_null(:exercises, :title, true)
  end
end
