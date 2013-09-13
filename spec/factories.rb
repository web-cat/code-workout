FactoryGirl.define do
  factory :organization do
    display_name "Virginia Tech"
    url_part "vt"
  end

  factory :term do
    season 100
    starts_on "2013-01-15"
    ends_on "2013-05-15"
    year 2013
    
    factory :term2 do
      season 400
      starts_on "2013-08-15"
      ends_on "2013-12-15"
    end
  end

  factory :course do
    name "Introduction to Software Design"
    number "CS 1114"
    organization_id 1
    # url_part "cs-1114"
  end

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
