require 'factory_bot'

namespace :db do
  desc "Reset database and then fill it with sample data"
  task populate: [:environment, :reset] do
    FactoryBot.create(:organization)
    FactoryBot.create(:term100)
    FactoryBot.create(:term200)
    FactoryBot.create(:term300)
    FactoryBot.create(:term400)
    FactoryBot.create(:term500)
    FactoryBot.create(:course)
    FactoryBot.create(:course_offering_term_1_tr)
    FactoryBot.create(:course_offering_term_1_mwf)
    FactoryBot.create(:course_offering_term_2_tr)
    FactoryBot.create(:course_offering_term_2_mwf)
    FactoryBot.create(:course_offering_term_3_tr)
    FactoryBot.create(:course_offering_term_3_mwf)
    FactoryBot.create(:course_offering_term_4_mwf)
    FactoryBot.create(:course_offering_term_4_tr)
    FactoryBot.create(:course_offering_term_5_mwf)
    FactoryBot.create(:course_offering_term_5_tr)

    t = Term.current_term
    cos = CourseOffering.where(term: Term.current_term)
    c = cos.first
    c2 = cos.second
    c3 = CourseOffering.where('term_id != ?', t.id).first

    FactoryBot.create(:course_enrollment,
      user: FactoryBot.create(:admin),
      course_offering: c,
      course_role: CourseRole.instructor)

    instructor = FactoryBot.create(:confirmed_user,
      first_name: 'Ima',
      last_name:  'Teacher',
      email:      "example-1@railstutorial.org")

    instructor2 = FactoryBot.create(:confirmed_user,
      first_name: 'Another',
      last_name: 'Teacher',
      email: 'example-2@railstutorial.org')

    FactoryBot.create(:course_enrollment,
      user: instructor,
      course_offering: c,
      course_role: CourseRole.instructor)

    FactoryBot.create(:course_enrollment,
      user: instructor,
      course_offering: c2,
      course_role: CourseRole.instructor)

    FactoryBot.create(:course_enrollment,
      user: instructor2,
      course_offering: c3,
      course_role: CourseRole.instructor)

    50.times do |n|
      co = nil
      if n < 16 
        co = c
      elsif n < 32
        co = c2
      else
        co = c3
      end
      FactoryBot.create(:course_enrollment,
        user: FactoryBot.create(:confirmed_user,
          first_name: Faker::Name.first_name,
          last_name:  Faker::Name.last_name,
          email:      "example-#{n+3}@railstutorial.org"),
        course_offering: co)
    end

    # Create a workout with one exercise, and a second exercise
    w = FactoryBot.create :workout_with_exercises
    FactoryBot.create :coding_exercise, name: 'Factorial 3'

    user_group = FactoryBot.create :user_group
    user_group.users << [ instructor, instructor2 ]

    group_owned_collection = FactoryBot.create :group_owned_collection, id: 1
    user_group.exercise_collection = group_owned_collection

    single_user_collection = FactoryBot.create :user_owned_collection
    instructor.exercise_collection = single_user_collection

    FactoryBot.create :mc_exercise, name: 'Pick One 3', exercise_collection: group_owned_collection
    FactoryBot.create :mc_exercise, name: 'Pick One 4', exercise_collection: group_owned_collection
    FactoryBot.create :coding_exercise, name: 'User Owned Coding', exercise_collection: single_user_collection
    FactoryBot.create :mc_exercise, name: 'User Owned MCQ', exercise_collection: single_user_collection

    # Create a workout_offering
    FactoryBot.create :workout_offering
    FactoryBot.create(:workout_offering,
      course_offering: c3,
      workout: w)
  end

  desc "Reset database and then fill it with Summer I 2015 data"
  task populate_su15: [:environment, :reset] do
    FactoryBot.create(:organization)
    FactoryBot.create(:term,
       season: 200,
       starts_on: "2015-05-25",
       ends_on: "2015-07-07",
       year: 2015)
    FactoryBot.create(:course)
    c = FactoryBot.create(:course_offering,
      self_enrollment_allowed: true,
      url: 'http://moodle.cs.vt.edu/course/view.php?id=282',
      label: '60396'
      )
    FactoryBot.create(:course_enrollment,
      user: FactoryBot.create(:admin),
      course_offering: c,
      course_role: CourseRole.instructor)
  end

end
