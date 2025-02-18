class UpgradeErrorsTable < ActiveRecord::Migration[5.2]

  # Upgrades the structure of the "errors" table used to store exception
  # data using the exception_handler gem. The gem changed the table structure
  # without including a corresponding migration of its own, so this migration
  # is intended to change the structure to match the gem's 0.8.0.0 version.

  #  The list of attributes from the exception model class in the gem:
  # ATTRS = %i(class_name status message trace target referrer params user_agent)

  # The old structure: (class_name message trace target_url referer_url params user_agent)

  def change
    change_table :errors do |t|
      t.rename :target_url, :target
      t.rename :referer_url, :referrer
      t.change :class_name, :text
      t.text :status
    end
  end
end
