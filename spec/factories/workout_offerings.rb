# == Schema Information
#
# Table name: workout_offerings
#
#  id                 :integer          not null, primary key
#  course_offering_id :integer
#  workout_id         :integer
#  created_at         :datetime
#  updated_at         :datetime
#  opening_date       :date
#  soft_deadline      :date
#  hard_deadline      :date
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :workout_offering do
    course_offering_id 1
    workout_id 1
  end
end
