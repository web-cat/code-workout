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

require 'spec_helper'

describe TagUserScore do
  pending "add some examples to (or delete) #{__FILE__}"
end
