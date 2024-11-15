class UpdateExercise < ActiveRecord::Migration[5.1]
  def change
  	#allow empty titles in database
  	change_column_null(:exercises, :title, true)
  end
end
