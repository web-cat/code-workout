# == Schema Information
#
# Table name: workouts
#
#  id                :integer          not null, primary key
#  name              :string(255)      not null
#  scrambled         :boolean          default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#  description       :text
#  target_group      :string(255)
#  points_multiplier :integer
#

require 'spec_helper'

describe Workout do
  pending "add some examples to (or delete) #{__FILE__}"
end
