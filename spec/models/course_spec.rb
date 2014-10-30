# == Schema Information
#
# Table name: courses
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  number          :string(255)      not null
#  organization_id :integer          not null
#  url_part        :string(255)      not null
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_courses_on_organization_id  (organization_id)
#  index_courses_on_url_part         (url_part) UNIQUE
#

require 'spec_helper'

describe Course do
  pending "add some examples to (or delete) #{__FILE__}"
end
