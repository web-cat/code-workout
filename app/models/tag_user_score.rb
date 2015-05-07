# == Schema Information
#
# Table name: tag_user_scores
#
#  id                  :integer          not null, primary key
#  user_id             :integer          not null
#  experience          :integer          default(0)
#  created_at          :datetime
#  updated_at          :datetime
#  completed_exercises :integer          default(0)
#
# Indexes
#
#  index_tag_user_scores_on_user_id  (user_id)
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
