# == Schema Information
#
# Table name: exercise_versions
#
#  id             :integer          not null, primary key
#  stem_id        :integer
#  name           :string(255)      not null
#  question       :text             not null
#  is_public      :boolean          not null
#  attempt_count  :integer          not null
#  correct_count  :float            not null
#  difficulty     :float            not null
#  discrimination :float            not null
#  created_at     :datetime
#  updated_at     :datetime
#  experience     :integer          not null
#  exercise_id    :integer          not null
#  position       :integer          not null
#  creator_id     :integer
#
# Indexes
#
#  index_exercise_versions_on_exercise_id  (exercise_id)
#  index_exercise_versions_on_stem_id      (stem_id)
#

class MultipleChoicePrompt < ExerciseVersion

  #~ Relationships ............................................................

  acts_as :prompt
  has_many :choices, -> { order("position ASC") },
    inverse_of: :multiple_choice_prompt, dependent: :destroy


  #~ Validation ...............................................................

	validates :allow_multiple, presence: true
	validates :is_scrambled, presence: true


  #~ Class methods.............................................................


  #~ Instance methods .........................................................

end
