# == Schema Information
#
# Table name: base_exercises
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  question_type      :integer
#  current_version_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#  versions           :integer
#  variation_group_id :integer
#

require 'rails_helper'

RSpec.describe BaseExercise, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
