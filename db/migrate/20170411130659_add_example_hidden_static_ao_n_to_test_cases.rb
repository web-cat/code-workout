class AddExampleHiddenStaticAoNToTestCases < ActiveRecord::Migration
  def change
    add_column :test_cases, :static, :boolean, null: false, default: false
    add_column :test_cases, :all_or_nothing, :boolean, null: false, default: false

    reversible do |dir|
      dir.up do
        add_column :test_cases, :example, :boolean, null: false, default: false
        execute <<-SQL
          UPDATE test_cases
            SET example = true
            WHERE description = 'example';
        SQL
        execute <<-SQL
          UPDATE test_cases
            SET example = true
            WHERE description LIKE 'example:%';
        SQL
        execute <<-SQL
          UPDATE test_cases
            SET description = NULL
            WHERE description = 'example';
        SQL
        execute <<-SQL
          UPDATE test_cases
            SET description = LTRIM(RIGHT(description, LENGTH(description) - LENGTH('example:')))
            WHERE description LIKE 'example:%';
        SQL
        add_column :test_cases, :hidden, :boolean, null: false, default: false
        execute <<-SQL
          UPDATE test_cases
            SET hidden = true
            WHERE description = 'hidden';
        SQL
        execute <<-SQL
          UPDATE test_cases
            SET hidden = true
            WHERE description LIKE 'hidden:%';
        SQL
        execute <<-SQL
          UPDATE test_cases
            SET description = NULL
            WHERE description = 'hidden';
        SQL
        execute <<-SQL
          UPDATE test_cases
            SET description = LTRIM(RIGHT(description, LENGTH(description) - LENGTH('hidden:')))
            WHERE description LIKE 'hidden:%';
        SQL
      end
      dir.down do
        # execute <<-SQL
          # UPDATE test_cases
            # SET description = 'example:' + description
            # WHERE description IS NOT NULL
              # AND description != ''
              # AND example = true;
          # UPDATE test_cases
            # SET description = 'example'
            # WHERE (description IS NULL or description = '') AND example = true;
        # SQL
        remove_column :test_cases, :example, :boolean, null: false, default: false
        # execute <<-SQL
          # UPDATE test_cases
            # SET description = 'hidden:' + description
            # WHERE description IS NOT NULL
              # AND description != ''
              # AND hidden = true;
          # UPDATE test_cases
            # SET description = 'hidden'
            # WHERE (description IS NULL or description = '') AND hidden = true;
        # SQL
        remove_column :test_cases, :hidden, :boolean, null: false, default: false
      end
    end
  end
end
