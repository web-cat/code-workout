# == Schema Information
#
# Table name: workouts
#
#  id                :integer          not null, primary key
#  name              :string(255)      default(""), not null
#  scrambled         :boolean          default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#  description       :text
#  points_multiplier :integer
#  creator_id        :integer
#  external_id       :string(255)
#  is_public         :boolean
#
# Indexes
#
#  index_workouts_on_external_id  (external_id) UNIQUE
#  index_workouts_on_is_public    (is_public)
#

require 'spec_helper'

describe Workout do
  pending "add some examples to (or delete) #{__FILE__}"
end
