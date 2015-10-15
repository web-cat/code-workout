# == Schema Information
#
# Table name: organizations
#
#  id           :integer          not null, primary key
#  name         :string(255)      default(""), not null
#  created_at   :datetime
#  updated_at   :datetime
#  abbreviation :string(255)
#  slug         :string(255)      default(""), not null
#
# Indexes
#
#  index_organizations_on_slug  (slug) UNIQUE
#

require 'spec_helper'

describe Organization do
  pending "add some examples to (or delete) #{__FILE__}"
end
