# == Schema Information
#
# Table name: choices
#
#  id         :integer          not null, primary key
#  prompt_id  :integer          not null
#  answer     :string(255)
#  order      :integer
#  feedback   :text
#  value      :float
#  created_at :datetime
#  updated_at :datetime
#

class Choice < ActiveRecord::Base
  #~ Relationships ............................................................

  belongs_to :prompt

  #~ Hooks ....................................................................

  #~ Validation ...............................................................

  validates :answer, presence: true, length: {minimum: 1}
  validates :order, presence: true, numericality: true
  validates :value, presence: true, numericality: true
  
  #~ Private instance methods .................................................
end
