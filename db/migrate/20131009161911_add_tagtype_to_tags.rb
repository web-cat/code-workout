class AddTagtypeToTags < ActiveRecord::Migration
  def change
    add_column :tags, :tagtype, :integer, :default => 0
  end
end
