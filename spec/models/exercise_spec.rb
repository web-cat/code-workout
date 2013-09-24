# == Schema Information
#
# Table name: exercises
#
#  id         :integer          not null, primary key
#  title      :string(255)      not null
#  preamble   :text
#  user       :integer          not null
#  is_public  :boolean          not null
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Exercise do
  pending "add some examples to (or delete) #{__FILE__}"
end
