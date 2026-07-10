class AddIpAddressToAttempts < ActiveRecord::Migration[5.2]
  def change
    add_column :attempts, :ip_address, :string
  end
end
