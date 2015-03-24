# == Schema Information
#
# Table name: exercises
#
#  id                 :integer          not null, primary key
#  stem_id            :integer
#  title              :string(255)
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
#  experience         :integer
#  base_exercise_id   :integer
#  version            :integer
#  creator_id         :integer
#
# Indexes
#
#  index_exercises_on_base_exercise_id  (base_exercise_id)
#  index_exercises_on_stem_id           (stem_id)
#

require 'spec_helper'

describe MultipleChoiceQuestion do
  pending "add some examples to (or delete) #{__FILE__}"
end
