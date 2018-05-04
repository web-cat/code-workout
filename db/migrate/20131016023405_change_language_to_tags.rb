class ChangeLanguageToTags < ActiveRecord::Migration
  def change
  	drop_table :languages
  	remove_column :exercises, :language_id
  end
end
