# == Schema Information
#
# Table name: courses
#
#  id              :integer          not null, primary key
#  name            :string(255)      default(""), not null
#  number          :string(255)      default(""), not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#  creator_id      :integer
#  slug            :string(255)      default(""), not null
#
# Indexes
#
#  index_courses_on_organization_id  (organization_id)
#  index_courses_on_slug             (slug)
#

require 'spec_helper'

describe Course do
  pending "add some examples to (or delete) #{__FILE__}"
end
