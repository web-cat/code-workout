# == Schema Information
#
# Table name: stems
#
#  id         :integer          not null, primary key
#  preamble   :text
#  created_at :datetime
#  updated_at :datetime
#

class Stem < ActiveRecord::Base

  #~ Relationships ............................................................

	has_many :exercises, inverse_of: :stem


  #~ Validation ...............................................................

	validates :preamble, presence: true, allow_blank: false

end
