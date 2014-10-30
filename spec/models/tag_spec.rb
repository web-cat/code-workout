# == Schema Information
#
# Table name: tags
#
#  id               :integer          not null, primary key
#  tag_name         :string(255)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  tagtype          :integer          default(0)
#  total_exercises  :integer          default(0)
#  total_experience :integer          default(0)
#

require 'spec_helper'

describe Tag do
  pending "add some examples to (or delete) #{__FILE__}"
end
