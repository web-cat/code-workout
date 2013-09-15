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
