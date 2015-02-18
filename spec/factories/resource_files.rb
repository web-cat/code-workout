# == Schema Information
#
# Table name: resource_files
#
#  id         :integer          not null, primary key
#  filename   :string(255)
#  token      :string(255)
#  user_id    :integer
#  public     :boolean          default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :resource_file do
  end
end
