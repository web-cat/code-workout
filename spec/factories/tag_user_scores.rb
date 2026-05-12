# == Schema Information
#
# Table name: tag_user_scores
#
#  id                  :bigint           not null, primary key
#  completed_exercises :integer          default(0)
#  experience          :integer          default(0)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :bigint           not null
#
# Indexes
#
#  index_tag_user_scores_on_experience  (experience)
#  index_tag_user_scores_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...                (user_id => users.id)
#  tag_user_scores_user_id_fk  (user_id => users.id)
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :tag_user_score do
  end
end
