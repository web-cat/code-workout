class AddReferenceSolutionToCodingPrompts < ActiveRecord::Migration
  def change
    add_column :coding_prompts, :reference_solution, :text
  end
end
