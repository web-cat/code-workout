# == Schema Information
#
# Table name: extension_managers
#
#  id              :bigint           not null, primary key
#  broker_base_url :string(255)      not null
#  client_secret   :string(255)      not null
#  name            :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_id       :string(255)      not null
#
# Indexes
#
#  index_extension_managers_on_broker_base_url  (broker_base_url) UNIQUE
#  index_extension_managers_on_client_id        (client_id) UNIQUE
#
class ExtensionManager < ApplicationRecord
  #~ Validation ...............................................................
  validates :name, presence: true
  validates :broker_base_url, presence: true, uniqueness: true
  validates :client_id, presence: true, uniqueness: true
  validates :client_secret, presence: true

  #~ Callbacks ................................................................
  before_validation :generate_credentials, on: :create

  private

  # -------------------------------------------------------------
  # Generate secure random credentials for the broker.
  def generate_credentials
    self.client_id ||= SecureRandom.hex(16)
    self.client_secret ||= SecureRandom.hex(32)
  end
end
