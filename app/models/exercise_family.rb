# == Schema Information
#
# Table name: exercise_families
#
#  id         :integer          not null, primary key
#  name       :string(255)      default(""), not null
#  created_at :datetime
#  updated_at :datetime
#

# =============================================================================
# Represents a collection of similar, highly overlapping exercises that
# are all minor variations on the same question.  For example, one question
# might ask a student to write a method X, while another might show code
# for the same method X with a MC prompt about identifying the location
# of a bug, while a third might give the student buggy code to edit and
# fix.
#
# Normally, one wouldn't want to give more than one of these closely
# related questions on a workout, and ExerciseFamily is intended to
# reflect the "closely related" nature of these variants of the same
# question--they are different Exercises, but in the same family.
#
class ExerciseFamily < ActiveRecord::Base

  #~ Relationships ............................................................

  has_many :exercises, inverse_of: :exercise_family, dependent: :nullify


  #~ Validation ...............................................................

  validates :name, presence: true

end
