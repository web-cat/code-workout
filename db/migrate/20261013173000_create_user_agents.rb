class CreateUserAgents < ActiveRecord::Migration[5.2]
  def change
    create_table :user_agents do |t|
      t.text :raw_user_agent, null: false
      t.string :user_agent_hash, limit: 64, null: false
      t.string :browser_family
      t.string :browser_version
      t.string :os_family
      t.boolean :is_lockdown, default: false, null: false
      t.boolean :is_seb, default: false, null: false
      t.boolean :is_suspicious, default: false, null: false

      t.timestamps
    end

    add_index :user_agents, :user_agent_hash, unique: true
    add_index :user_agents, :browser_family
    add_index :user_agents, :os_family
    add_index :user_agents, :is_lockdown
    add_index :user_agents, :is_seb
    add_index :user_agents, :is_suspicious
  end
end
