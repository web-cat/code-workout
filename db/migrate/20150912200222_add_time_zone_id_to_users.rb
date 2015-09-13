class AddTimeZoneIdToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :time_zone, index: true
  end
end
