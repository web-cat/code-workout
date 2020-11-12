class AddTimeZoneIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :time_zone, index: true
  end
end
