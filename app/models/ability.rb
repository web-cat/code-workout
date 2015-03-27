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

      # Creating an alias for CRUD operations
      alias_action :create, :read, :update, :destroy, to: :crud

      # A user should only be able to update himself or herself (assuming no
      # other permissions granted below by the global role).
      can [:show, :edit, :update], User do |target_user|
        target_user.id == user.id
      end

      cannot :index, [User, Workout, Exercise, CourseEnrollment] unless
        user.global_role.can_edit_system_configuration?

      cannot :crud, [Organization, GlobalRole, CourseRole] unless
        user.global_role.can_edit_system_configuration?

      cannot [:update, :edit, :destroy], [CourseEnrollment] do |ce|
        role = CourseEnrollment.find_by(
          user_id: user.id, course_offering_id: ce.course_offering.id)
        role.nil? || !role.course_role.can_manage_course?
      end

      cannot :show, CourseEnrollment do |ce|
        ce.user_id != user.id
      end

      cannot :new, CourseEnrollment unless user.global_role.is_instructor?

      #~ CourseOffering and Course
      cannot [:create, :new], [CourseOffering, Course] unless
        (user.global_role.can_edit_system_configuration? ||
        user.global_role.is_instructor?)

      # FIXME: These belong in process_courses, and they probably
      # need to be rewritten and/or removed anyway:

#      cannot [:update, :generate_gradebook, :add_workout, :edit, :destroy],
#        CourseOffering do |co|
#        role = CourseEnrollment.find_by(
#          user_id: user.id, course_offering_id: co.id)
#        role.nil? || !role.course_role.can_manage_course?
#      end

#      cannot [:update, :generate_gradebook, :edit, :destroy], Course do |co|
#        co.creator_id != user.id
#      end

      #~ Exercise and Workout
      # Tighter permissions to remain till beginning of Fall 2015
      cannot [:create, :new], Exercise unless
        user.global_role.can_edit_system_configuration? ||
        user.global_role.is_instructor?
      cannot [:update, :edit, :destroy], Exercise do |ex|
        ex.creator_id != user.id
      end
      can [:update, :edit, :destroy], Exercise do |ex|
        ex.creator_id == user.id
      end

      cannot [:create, :new], Workout unless
        user.global_role.can_edit_system_configuration? ||
        user.global_role.is_instructor?
      cannot [:update, :edit, :destroy], Workout do |wkt|
        wkt.creator_id != user.id
      end
      can [:update, :edit, :destroy], Workout do |wkt|
        wkt.creator_id == user.id
      end

      #~ Resource files
      cannot [:create, :new], ResourceFile unless
        user.global_role.can_edit_system_configuration?
      cannot [:update, :edit, :show, :destroy], ResourceFile do |res|
        res.user_id != user.id
      end
      can [:update, :edit, :show, :destroy], ResourceFile do |res|
        res.user_id == user.id
      end

      #~ Signups
      # cannot [:update, :index, :edit, :show, :destroy], Signup unless
      #   user.global_role.can_edit_system_configuration?

      process_global_role user
      process_instructor user
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
      can [:create, :new],
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
    # A user can manage a CourseOffering if they are enrolled in that
    # offering and have a CourseRole where can_manage_course? is true.

    can :read, CourseOffering do |co|
      co.enrolled? user
    end
    can [:manage, :generate_gradebook], CourseOffering do |co|
      co.manages? user
    end

    # Likewise, a user can only manage enrollments in a CourseOffering
    # that they have can_manage_courses? permission in.
    can :manage, CourseEnrollment do |enrollment|
      enrollment.course_offering.manages? user
    end
  end

end
