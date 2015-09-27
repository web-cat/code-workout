class StudentExtension < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :workout_offering
end
