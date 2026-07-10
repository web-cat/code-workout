class AddIpAddressToVisualizationLoggings < ActiveRecord::Migration[5.2]
  def change
    add_column :visualization_loggings, :ip_address, :string
  end
end
