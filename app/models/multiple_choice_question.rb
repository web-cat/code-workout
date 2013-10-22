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

class MultipleChoiceQuestion < Exercise
	
#~ Validation ...............................................................
	validates :mcq_allow_multiple, presence: true
	validates :mcq_is_scrambled, presence: true

#~ Class methods.............................................................
  
  # -------------------------------------------------------------
  

  #~ Instance methods .........................................................
  def get_choices
  	#TODO randomize order of choices if is_scrambled is true
  
  end

  def scrambled?
  	mcq_is_scrambled
  end

  def choose_multiple?
  	mcq_allow_multiple
  end

end
