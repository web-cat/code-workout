class AddGradingTypeToParsonsPrompts < ActiveRecord::Migration[5.2]
  def change
    add_column :parsons_prompts, :grading_type, :string,
      null: false, default: 'order'
  end
end
