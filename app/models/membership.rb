class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_group
end
