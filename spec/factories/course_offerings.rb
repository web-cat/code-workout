# == Schema Information
#
# Table name: course_offerings
#
#  id                      :integer          not null, primary key
#  cutoff_date             :date
#  label                   :string(255)      default(""), not null
#  self_enrollment_allowed :boolean
#  url                     :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  course_id               :integer          not null
#  lms_course_id           :string(255)
#  lms_instance_id         :integer
#  lms_section_id          :string(255)
#  lti_context_id          :string(255)
#  term_id                 :integer          not null
#
# Indexes
#
#  index_course_offerings_on_course_id        (course_id)
#  index_course_offerings_on_lms_instance_id  (lms_instance_id)
#  index_course_offerings_on_term_id          (term_id)
#
# Foreign Keys
#
#  course_offerings_course_id_fk  (course_id => courses.id)
#  course_offerings_term_id_fk    (term_id => terms.id)
#

FactoryBot.define do

  factory :course_offering do
    course_id { 1 }
    url { "http://courses.cs.vt.edu/~cs2114/Fall2013" }
    self_enrollment_allowed { true }

    factory :course_offering_term_1_tr do
      term_id { 1 }
      label { "TR 11:00am" }
    end

    factory :course_offering_term_1_mwf do
      term_id { 1 }
      label { "MWF 10:00am" }
    end

    factory :course_offering_term_2_tr do
      term_id { 2 }
      label { "TR 11:00am" }
    end

    factory :course_offering_term_2_mwf do
      term_id { 2 }
      label { "MWF 10:00am" }
    end

    factory :course_offering_term_3_tr do
      term_id { 3 }
      label { "TR 11:00am" }
    end

    factory :course_offering_term_3_mwf do
      term_id { 3 }
      label { "MWF 10:00am" }
    end

    factory :course_offering_term_4_mwf do
      term_id { 4 }
      label { "MWF 10:00am" }
    end

    factory :course_offering_term_4_tr do
      term_id { 4 }
      label { "TR 10:00am" }
    end

    factory :course_offering_term_5_mwf do
      term_id { 5 }
      label { "MWF 10:00am" }
    end

    factory :course_offering_term_5_tr do
      term_id { 5 }
      label { "TR 10:00am" }
    end
  end

end
