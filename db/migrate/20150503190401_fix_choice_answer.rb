class FixChoiceAnswer < ActiveRecord::Migration
  def up
    remove_column :choices, :answer
    add_column :choices, :answer, :text
    change_column_null :choices, :answer, false
  end

  def down
    # Actually, this is a no-op going backward--we're just fixing the
    # invalid 255-char limit stuck to this text field
  end
end
