class ChangeLanguageToTags < ActiveRecord::Migration[5.1]
  def change
  	drop_table :languages
  	remove_column :exercises, :language_id
  end
end
