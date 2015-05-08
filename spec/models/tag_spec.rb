# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  taggings_count :integer          default(0)
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#

require 'spec_helper'

describe Tag do
  pending "add some examples to (or delete) #{__FILE__}"
end
