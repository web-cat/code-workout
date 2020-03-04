# == Schema Information
#
# Table name: user_groups
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  description :text(65535)
#

require 'spec_helper'

describe UserGroup, :type => :model do
  before :all do
    @user_group = UserGroup.find(1)
    @user = User.find(2)
  end

  describe '#is_a_member_of?' do
    it 'should return true if a user is a member of this group' do
      expect(@user.is_a_member_of?(@user_group)).to eq(true)
    end

    it 'should return false if a user is not a member of this group' do
      outsider = User.not_in_group(@user_group).first
      expect(outsider.is_a_member_of?(@user_group)).to eq(false)
    end
  end
end
