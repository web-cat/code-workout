class Language < ActiveRecord::Base
	validates :name, presence: true
end
