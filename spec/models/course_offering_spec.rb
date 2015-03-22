# == Schema Information
#
# Table name: course_offerings
#
#  id                      :integer          not null, primary key
#  course_id               :integer
#  term_id                 :integer
#  name                    :string(255)
#  label                   :string(255)
#  url                     :string(255)
#  self_enrollment_allowed :boolean
#  created_at              :datetime
#  updated_at              :datetime
#

require 'spec_helper'

describe CourseOffering do
  pending "add some examples to (or delete) #{__FILE__}"
end
