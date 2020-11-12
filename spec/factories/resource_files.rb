# == Schema Information
#
# Table name: resource_files
#
#  id         :integer          not null, primary key
#  filename   :string(255)
#  public     :boolean          default(TRUE)
#  token      :string(255)      default(""), not null
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer          not null
#
# Indexes
#
#  index_resource_files_on_token    (token)
#  index_resource_files_on_user_id  (user_id)
#
# Foreign Keys
#
#  resource_files_user_id_fk  (user_id => users.id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :resource_file do
  end
end
