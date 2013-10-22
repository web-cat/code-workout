class Stem < ActiveRecord::Base

	has_many :exercises

	validates :preamble, presence: true
end
