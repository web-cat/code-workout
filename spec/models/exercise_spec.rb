# == Schema Information
#
# Table name: exercises
#
#  id                 :integer          not null, primary key
#  question_type      :integer          not null
#  current_version_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#  versions           :integer
#  exercise_family_id :integer
#  name               :string(255)
#  is_public          :boolean          default(FALSE), not null
#  experience         :integer          not null
#  irt_data_id        :integer
#  external_id        :string(255)
#
# Indexes
#
#  index_exercises_on_current_version_id  (current_version_id)
#  index_exercises_on_exercise_family_id  (exercise_family_id)
#  index_exercises_on_external_id         (external_id) UNIQUE
#

require 'spec_helper'

describe Exercise do
  pending "add some examples to (or delete) #{__FILE__}"
end
