require 'factory_girl'

namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    FactoryGirl.create(:organization)
    FactoryGirl.create(:term)
    FactoryGirl.create(:term2)
    FactoryGirl.create(:course)
    FactoryGirl.create(:course_offering)
    FactoryGirl.create(:course_offering2)

    FactoryGirl.create(:admin)
    FactoryGirl.create(:instructor_user,
        first_name: 'Ima',
        last_name:  'Teacher',
        email:      "example-1@railstutorial.org")
    50.times do |n|
      u = FactoryGirl.create(:confirmed_user,
        first_name: Faker::Name.first_name,
        last_name:  Faker::Name.last_name,
        email:      "example-#{n+2}@railstutorial.org")
    end
  end
end
