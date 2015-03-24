# == Schema Information
#
# Table name: choices
#
#  id          :integer          not null, primary key
#  exercise_id :integer          not null
#  answer      :string(255)
#  order       :integer
#  feedback    :text
#  value       :float
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_choices_on_exercise_id  (exercise_id)
#

class Choice < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :exercise, inverse_of: :choices


  #~ Hooks ....................................................................

  #~ Validation ...............................................................

  validates :answer, presence: true, allow_blank: false
  validates :order, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :value, presence: true,
    numericality: { greater_than_or_equal_to: 0 }


  #~ Private instance methods .................................................
end
