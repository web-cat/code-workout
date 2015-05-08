# == Schema Information
#
# Table name: exercise_versions
#
#  id                 :integer          not null, primary key
#  stem_id            :integer
#  name               :string(255)      not null
#  question           :text             not null
#  feedback           :text
#  is_public          :boolean          not null
#  priority           :integer          not null
#  count_attempts     :integer          not null
#  count_correct      :float            not null
#  difficulty         :float            not null
#  discrimination     :float            not null
#  mcq_allow_multiple :boolean
#  mcq_is_scrambled   :boolean
#  created_at         :datetime
#  updated_at         :datetime
#  experience         :integer          not null
#  exercise_id        :integer          not null
#  position           :integer          not null
#  creator_id         :integer
#
# Indexes
#
#  index_exercise_versions_on_exercise_id  (exercise_id)
#  index_exercise_versions_on_stem_id      (stem_id)
#

require 'spec_helper'

describe MultipleChoiceQuestion do
  pending "add some examples to (or delete) #{__FILE__}"
end
