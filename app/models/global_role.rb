# == Schema Information
#
# Table name: global_roles
#
#  id                            :integer          not null, primary key
#  name                          :string(255)      default(""), not null
#  can_manage_all_courses        :boolean          default(FALSE), not null
#  can_edit_system_configuration :boolean          default(FALSE), not null
#  builtin                       :boolean          default(FALSE), not null
#

# =============================================================================
# Represents a user's global permissions on the system.  This has now
# degenerated into what ammounts to a global "administrator" flag.
#
class GlobalRole < ActiveRecord::Base

  #~ Validation ...............................................................

  validates :name, presence: true, uniqueness: true

  with_options if: :builtin?, on: :update, changeable: false do |builtin|
    builtin.validates :can_edit_system_configuration
    builtin.validates :can_manage_all_courses
  end

  before_destroy :check_builtin?


  #~ Constants ................................................................

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


  # -------------------------------------------------------------
  def is_instructor?
    id == INSTRUCTOR_ID
  end


  # -------------------------------------------------------------
  def is_admin?
    id == ADMINISTRATOR_ID
  end


  # -------------------------------------------------------------
  def is_regular_user?
    id == REGULAR_USER_ID
  end

end
