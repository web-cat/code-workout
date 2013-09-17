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

class MultipleChoiceQuestion < Prompt
	
#~ Validation ...............................................................
	validates :allow_multiple, presence: true
	validates :is_scrambled, presence: true

#~ Class methods.............................................................
  
  # -------------------------------------------------------------
  

  #~ Instance methods .........................................................
  def get_choices

  	ans = self.choices
  	#TODO randomize order of choices if is_scrambled is true
  	if is_scrambled
  		return ans
  	else
  		return ans
  	end
  end

  def scrambled?
  	is_scrambled
  end

  def choose_multiple?
  	allow_multiple
  end

end
