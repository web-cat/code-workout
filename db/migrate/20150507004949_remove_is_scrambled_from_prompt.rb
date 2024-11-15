class RemoveIsScrambledFromPrompt < ActiveRecord::Migration[5.1]
  def change
    remove_column :prompts, :is_scrambled, :boolean
  end
end
