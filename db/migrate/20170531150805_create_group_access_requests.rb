class CreateGroupAccessRequests < ActiveRecord::Migration
  def change
    create_table :group_access_requests do |t|
      t.references :user, index: true, foreign_key: true
      t.references :user_group, index: true, foreign_key: true
      t.boolean :pending, default: true
      t.boolean :decision, default: nil

      t.timestamps
    end
  end
end
