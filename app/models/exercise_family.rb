# == Schema Information
#
# Table name: exercise_families
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class ExerciseFamily < ActiveRecord::Base

  #~ Relationships ............................................................

  has_many :exercises, inverse_of: :exercise_family, dependent: :nullify


  #~ Validation ...............................................................

  validates :name, presence: true

end
