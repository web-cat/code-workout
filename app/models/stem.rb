# == Schema Information
#
# Table name: stems
#
#  id         :integer          not null, primary key
#  preamble   :text(65535)
#  created_at :datetime
#  updated_at :datetime
#


# =============================================================================
# Represents the stem, or preamble, for an exercise.  The stem is introductory
# text that serves as the problem setup or describes the context of the
# exercise.  It is separate from the prompt--the prompt is the actual
# question to be answered.
#
# In many simple exercises that have a single prompt, the distinction between
# stem and prompt may not be very relevant, and the whole text might be
# considered "the question".  However, in a multi-part question, the
# prompts correspond to the a), b), c), etc., parts to be individually
# answered, and the stem corresponds to the introductory text that
# precedes all of the prompts/parts.
#
# A stem is associated with one or more ExerciseVersions.  Several
# ExerciseVersions on the same edit history for one exercise may refer
# to the same stem, if the stem was not edited.
#
class Stem < ActiveRecord::Base

  #~ Relationships ............................................................

	has_many :exercise_versions, inverse_of: :stem


  #~ Validation ...............................................................

	validates :preamble, presence: true

end
