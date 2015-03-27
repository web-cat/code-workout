# == Schema Information
#
# Table name: tag_user_scores
#
#  id                  :integer          not null, primary key
#  user_id             :integer          not null
#  tag_id              :integer          not null
#  experience          :integer          default(0)
#  created_at          :datetime
#  updated_at          :datetime
#  completed_exercises :integer          default(0)
#
# Indexes
#
#  index_tag_user_scores_on_tag_id   (tag_id)
#  index_tag_user_scores_on_user_id  (user_id)
#

class TagUserScore < ActiveRecord::Base

  #~ Relationships ............................................................

	belongs_to :user, inverse_of: :tag_user_scores
	belongs_to :tag, inverse_of: :tag_user_scores


  #~ Validation ...............................................................

  validates :user, presence: true
  validates :tag, presence: true

end
