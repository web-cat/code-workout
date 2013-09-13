require 'factory_girl'

namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    require File.expand_path('spec/factories.rb')

    FactoryGirl.create(:organization)
    FactoryGirl.create(:term)
    FactoryGirl.create(:term2)
    FactoryGirl.create(:course)
    FactoryGirl.create(:course_offering)
    FactoryGirl.create(:course_offering2)
  end
end
