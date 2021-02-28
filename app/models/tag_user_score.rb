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

# =============================================================================
# Represents a user's xp score for a given tag.
#
class TagUserScore < ActiveRecord::Base

  #~ Relationships ............................................................

  acts_as_taggable
	belongs_to :user, inverse_of: :tag_user_scores
  has_and_belongs_to_many :attempts


  #~ Validation ...............................................................

  validates :user, presence: true

end
