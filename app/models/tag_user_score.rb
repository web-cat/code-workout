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

# =============================================================================
# Represents a user's xp score for a given tag.
#
class TagUserScore < ApplicationRecord

  #~ Relationships ............................................................

  acts_as_taggable
	belongs_to :user, inverse_of: :tag_user_scores
  has_and_belongs_to_many :attempts


  #~ Validation ...............................................................

  validates :user, presence: true

end
