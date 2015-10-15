# == Schema Information
#
# Table name: course_offerings
#
#  id                      :integer          not null, primary key
#  course_id               :integer          not null
#  term_id                 :integer          not null
#  label                   :string(255)      default(""), not null
#  url                     :string(255)
#  self_enrollment_allowed :boolean
#  created_at              :datetime
#  updated_at              :datetime
#  cutoff_date             :date
#
# Indexes
#
#  index_course_offerings_on_course_id  (course_id)
#  index_course_offerings_on_term_id    (term_id)
#

FactoryGirl.define do

  factory :course_offering do
    course_id 1
    term_id 1
    label "MWF 10:00am"
    url "http://courses.cs.vt.edu/~cs2114/Fall2013"
    self_enrollment_allowed false

    factory :course_offering2 do
      label "TR 11:00am"
    end
  end

end
