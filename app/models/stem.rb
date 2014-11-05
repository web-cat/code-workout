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

	has_many :exercises

	validates :preamble, presence: true
end
