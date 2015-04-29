# == Schema Information
#
# Table name: choices
#
#  id          :integer          not null, primary key
#  exercise_id :integer          not null
#  answer      :string(255)      not null
#  order       :integer          not null
#  feedback    :text
#  value       :float            not null
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_choices_on_exercise_id  (exercise_id)
#

class Choice < ActiveRecord::Base

  #~ Relationships ............................................................

  belongs_to :exercise_version, inverse_of: :choices


  #~ Hooks ....................................................................

  #~ Validation ...............................................................

  validates :exercise_version, presence: true
  validates :answer, presence: true
  validates :order, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :value, presence: true,
    numericality: { greater_than_or_equal_to: 0 }


  #~ Private instance methods .................................................
end
