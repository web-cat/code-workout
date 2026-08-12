class UpgradeErrorsTable < ActiveRecord::Migration[5.2]

  # Upgrades the structure of the "errors" table used to store exception
  # data using the exception_handler gem. The gem changed the table structure
  # without including a corresponding migration of its own, so this migration
  # is intended to change the structure to match the gem's 0.8.0.0 version.

  #  The list of attributes from the exception model class in the gem:
  # ATTRS = %i(class_name status message trace target referrer params user_agent)

  # The old structure: (class_name message trace target_url referer_url params user_agent)

  def change
    if table_exists?(:errors)
      change_table :errors do |t|
        if column_exists?(:errors, :target_url) && !column_exists?(:errors, :target)
          t.rename :target_url, :target
        end
        if column_exists?(:errors, :referer_url) && !column_exists?(:errors, :referrer)
          t.rename :referer_url, :referrer
        end
        t.change :class_name, :text if column_exists?(:errors, :class_name)
        t.text :status unless column_exists?(:errors, :status)
      end
    end
  end
end
