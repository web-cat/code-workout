class AddTagtypeToTags < ActiveRecord::Migration[5.1]
  def change
    add_column :tags, :tagtype, :integer, :default => 0
  end
end
