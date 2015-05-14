class ActableIdsAreNotUnique < ActiveRecord::Migration
  def up
    # Remove unique: true from these two indices
    remove_index :prompts, :actable_id
    remove_index :prompt_answers, :actable_id
    add_index :prompts, :actable_id
    add_index :prompt_answers, :actable_id
  end
  def down
    # No-op, since adding uniqueness constraints will likely break
    # existing data, and isn't needed by older/legacy code anyway.
  end
end
