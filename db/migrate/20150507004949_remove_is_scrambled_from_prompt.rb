class RemoveIsScrambledFromPrompt < ActiveRecord::Migration
  def change
    remove_column :prompts, :is_scrambled, :boolean
  end
end
