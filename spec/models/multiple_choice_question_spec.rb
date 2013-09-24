# == Schema Information
#
# Table name: prompts
#
#  id                :integer          not null, primary key
#  exercise_id       :integer          not null
#  language_id       :integer          not null
#  instruction       :text             not null
#  order             :integer          not null
#  max_user_attempts :integer
#  attempts          :integer
#  correct           :float
#  feedback          :text
#  difficulty        :float            not null
#  discrimination    :float            not null
#  type              :integer          not null
#  allow_multiple    :boolean
#  is_scrambled      :boolean
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'

describe MultipleChoiceQuestion do
  pending "add some examples to (or delete) #{__FILE__}"
end
