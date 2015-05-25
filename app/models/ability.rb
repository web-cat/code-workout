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
    # default abilities for anonymous, non-logged-in visitors
    can :read, Term
    can :read, Organization
    can :read, Course

    if user
      # This ability allows admins impersonating other users to revert
      # back to their original user.
      can :unimpersonate, User

      # Global admin permissions
      can :manage, :all if user.global_role.is_admin?

      # Creating an alias for CRUD operations
      alias_action :create, :read, :update, :destroy, to: :crud

      # A user should only be able to update himself or herself (assuming no
      # other permissions granted below by the global role).
      can [:show, :update], User, id: user.id

      process_global_role user
      process_instructor user
      process_courses user
      process_exercises user
      process_workouts user
      process_resource_files user
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
    # Extensive permission for System Admins till beginning of Fall 2015
      can :manage, User
      can :manage, Workout
      can :manage, Exercise
      can :manage, ResourceFile
      can :crud, CourseEnrollment

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
  def process_instructor(user)
    if user.global_role.is_instructor?
      # FIXME: The exercise/workout permissions need to be role-based
      # with respect to the course offering, rather than depending on the
      # global role.
      can [:create],
        [Course, CourseOffering, Exercise, ResourceFile, Workout]
      can [:index], [Exercise, Workout]
    end
  end


  # -------------------------------------------------------------
  # Private: Process course-related permissions.
  #
  # user - the user
  #
  def process_courses(user)
    # Everyone can manage their own course enrollments
    can :manage, CourseEnrollment, user_id: user.id

    # Everyone can read the course offerings they are enrolled in
    can :read, CourseOffering do |co|
      co.is_enrolled? user
    end

    # A user can manage a CourseOffering if they are enrolled in that
    # offering and have a CourseRole where can_manage_course? is true.
    can [:manage], CourseOffering do |co|
      co.managed_by? user
    end

    # A user can grade a CourseOffering if they are enrolled in that
    # offering and have a CourseRole where can_grade_submissions? is true.
    can [:generate_gradebook], CourseOffering do |co|
      co.graded_by? user
    end

    # Likewise, a user can only manage enrollments in a CourseOffering
    # that they have can_manage_courses? permission in.
    can :manage, CourseEnrollment do |enrollment|
      enrollment.course_offering.managed_by? user
    end
  end


  # -------------------------------------------------------------
  def process_exercises(user)
    # Tighter permissions to remain till beginning of Fall 2015
    can :create, Exercise if user.global_role.is_instructor?
    can [:read, :update, :destroy], Exercise, creator_id: user.id
  end


  # -------------------------------------------------------------
  def process_workouts(user)
    # Tighter permissions to remain till beginning of Fall 2015
    can :create, Workout if user.global_role.is_instructor?
    can [:read, :update, :destroy], Workout, creator_id: user.id
  end


  # -------------------------------------------------------------
  def process_resource_files(user)
    # Tighter permissions to remain till beginning of Fall 2015
    can :create, ResourceFile if
      user.global_role.can_edit_system_configuration?
    can [:read, :update, :destroy], ResourceFile, user_id: user.id
  end

end
