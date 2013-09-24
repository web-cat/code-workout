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

require 'spec_helper'

describe Choice do
  pending "add some examples to (or delete) #{__FILE__}"
end
