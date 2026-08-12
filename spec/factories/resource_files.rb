# == Schema Information
#
# Table name: resource_files
#
#  id         :bigint           not null, primary key
#  filename   :string(255)
#  hashval    :string(255)
#  public     :boolean          default(TRUE)
#  token      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_resource_files_on_hashval  (hashval)
#  index_resource_files_on_token    (token)
#  index_resource_files_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...               (user_id => users.id)
#  resource_files_user_id_fk  (user_id => users.id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :resource_file do
  end
end
