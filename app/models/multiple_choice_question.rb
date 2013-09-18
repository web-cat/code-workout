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
