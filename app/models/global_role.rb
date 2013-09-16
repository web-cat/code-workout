class GlobalRole < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true
  
  with_options if: :builtin?, on: :update, changeable: false do |builtin|
    builtin.validates :can_edit_system_configuration
    builtin.validates :can_manage_all_courses
  end

  before_destroy :check_builtin?


  # Make sure to run rake db:seed after initial database creation
  # to ensure that the built-in roles with these IDs are created.
  # These IDs should not be referred to directly in most cases;
  # use the class methods below to fetch the actual role object
  # instead.
  ADMINISTRATOR_ID = 1
  INSTRUCTOR_ID    = 2
  REGULAR_USER_ID  = 3


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.administrator
    find(ADMINISTRATOR_ID)
  end


  # -------------------------------------------------------------
  def self.instructor
    find(INSTRUCTOR_ID)
  end


  # -------------------------------------------------------------
  def self.regular_user
    find(REGULAR_USER_ID)
  end


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def check_builtin?
    errors.add :base, "Cannot delete built-in roles." if builtin?
    errors.blank?
  end

end
