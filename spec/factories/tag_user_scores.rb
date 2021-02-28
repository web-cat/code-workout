# == Schema Information
#
# Table name: tag_user_scores
#
#  id                  :integer          not null, primary key
#  completed_exercises :integer          default(0)
#  experience          :integer          default(0)
#  created_at          :datetime
#  updated_at          :datetime
#  user_id             :integer          not null
#
# Indexes
#
#  index_tag_user_scores_on_user_id  (user_id)
#
# Foreign Keys
#
#  tag_user_scores_user_id_fk  (user_id => users.id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :tag_user_score do
  end
end
