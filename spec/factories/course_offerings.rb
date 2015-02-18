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

FactoryGirl.define do

  factory :course_offering do
    course_id 1
    term_id 1
    name "1234"
    label "MWF 10:00am"
    url "http://courses.cs.vt.edu/~cs2114/Fall2013"
    self_enrollment_allowed false
    
    factory :course_offering2 do
      name "5432"
      label "TR 11:00am"
    end
  end

end
