class ChangeLanguageToTags < ActiveRecord::Migration[5.1]
  def change
  	drop_table :languages
  	# remove_column :exercises, :language_id
    # already removed in db/migrate/20131010184442_change_tags_in_exercise.rb
  end
end
