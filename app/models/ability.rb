# =============================================================================
# The Ability class is used by CanCan to control how users with various roles
# can access resources in CodeWorkout.
#
class Ability
  include CanCan::Ability

  # -------------------------------------------------------------
  # Public: Initialize the Ability with the permissions of the specified
  # User.
  #
  # user - the user
  #
  def initialize(user)
    if user
      # This ability allows admins impersonating other users to revert
      # back to their original user.
      can :unimpersonate, User

      # A user should only be able to update himself or herself (assuming no
      # other permissions granted below by the global role).
      can [:show, :update], User do |target_user|
        target_user == user
      end

      can :index, User if user.global_role.can_edit_system_configuration?
      
      # All users can create these, Piazza-style
      can :create, Course
      can :create, CourseOffering

      process_global_role user
      process_courses user
#      process_assignments user
#      process_repositories user
#      process_assignment_checks user
#      process_media_items user
    end
  end


  private

  # -------------------------------------------------------------
  # Private: Grant permissions from the user's global role.
  #
  # user - the user
  #
  def process_global_role(user)
    # Grant management access to most things through the
    # GlobalRole.can_edit_system_configuration? permission.
    #
    # TODO: This permission does too much. We probably want to separate
    # out things like ActivityLog, SystemConfiguration, User, and the roles
    # from Organization, for example.
    if user.global_role.can_edit_system_configuration?
#      can :manage, ActivityLog
      can :manage, CourseRole
#      can :manage, Environment
      can :manage, GlobalRole
      can :manage, Organization
      can :manage, Term
#      can :manage, SystemConfiguration
      can :manage, User
    end

    # Grant broad course management access through the
    # GlobalRole.can_manage_all_courses? permission.
    if user.global_role.can_manage_all_courses?
      can :manage, Course
      can :manage, CourseOffering
      can :manage, CourseEnrollment
    end

  end


  # -------------------------------------------------------------
  # Private: Process course-related permissions.
  #
  # user - the user
  #
  def process_courses(user)
    # A user can manage a CourseOffering if they are enrolled in that
    # offering and have a CourseRole where can_manage_course? is true.

    can :read, CourseOffering, user.course_offerings do |offering|
      true
    end

    can :manage, CourseOffering, user.managing_course_offerings do |offering|
      true
    end

    # Likewise, a user can only manage enrollments in a CourseOffering
    # that they have can_manage_courses? permission in.
    can :manage, CourseEnrollment do |enrollment|
      user_enrollment = CourseEnrollment.where(
        user_id: user.id,
        course_offering_id: enrollment.course_offering.id).first

      user_enrollment && user_enrollment.course_role.can_manage_course?
    end
  end

end
