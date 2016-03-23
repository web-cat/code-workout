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
    can [:read, :index], [Term, Organization, Course, CourseOffering]

    if user
      # This ability allows admins impersonating other users to revert
      # back to their original user.
      can :unimpersonate, User

      # Creating an alias for CRUD operations
      alias_action :create, :read, :update, :destroy, to: :crud

      # Global admin permissions, placed last override everything
      if user.global_role.id == GlobalRole::ADMINISTRATOR_ID
        can :manage, :all
      else

        # A user should only be able to update himself or herself (assuming no
        # other permissions granted below by the global role).
        can [:read, :index], User, User.visible_to_user(user) do |u|
          u == user || u.course_enrollments.where{
            course_role_id != CourseRole::STUDENT_ID}.any?
        end
        can [:edit, :update], User, id: user.id

        process_global_role user
        process_instructor user
        process_courses user
        process_exercises user
        process_workouts user
        process_resource_files user
      end
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
      can :manage, [
        CourseRole,
        GlobalRole,
        Organization,
        Term,
        User,
        Course,
        CourseOffering,
        CourseEnrollment,
        Workout,
        Exercise,
        Attempt,
        ResourceFile
      ]
    end

    # Grant broad course management access through the
    # GlobalRole.can_manage_all_courses? permission.
    if user.global_role.can_manage_all_courses?
      can :manage, [Course, CourseOffering, CourseEnrollment,
        Workout, Exercise, Attempt, ResourceFile]
    end

  end


  # -------------------------------------------------------------
  def process_instructor(user)
    if user.global_role.is_instructor? &&
      !user.global_role.can_manage_all_courses?
      # FIXME: The exercise/workout permissions need to be role-based
      # with respect to the course offering, rather than depending on the
      # global role.
      can [:create], [Course, CourseOffering, CourseEnrollment,
        Workout, Exercise, Attempt, ResourceFile]

      can [:index], [Workout, Exercise, Attempt, ResourceFile]
    end
  end


  # -------------------------------------------------------------
  # Private: Process course-related permissions.
  #
  # user - the user
  #
  def process_courses(user)
    if !user.global_role.can_edit_system_configuration? &&
      !user.global_role.can_manage_all_courses?

      # Everyone can manage their own course enrollments
      can :manage, CourseEnrollment, user_id: user.id

      can :enroll, CourseOffering, self_enrollment_allowed: true

      can :unenroll, CourseOffering

      # A user can manage a CourseOffering if they are enrolled in that
      # offering and have a CourseRole where can_manage_course? is true.
      can [:edit, :update], CourseOffering,
        CourseOffering.managed_by_user(user) do |co|
        co.is_manager? user
      end

      # A user can grade a CourseOffering if they are enrolled in that
      # offering and have a CourseRole where can_grade_submissions? is true.
      can :generate_gradebook, CourseOffering do |co|
        co.is_staff? user
      end

      # Likewise, a user can only manage enrollments in a CourseOffering
      # that they have can_manage_courses? permission in.
      can :manage, CourseEnrollment do |enrollment|
        enrollment.course_offering.is_manager? user
      end
    end
  end


  # -------------------------------------------------------------
  def process_exercises(user)
    # Everyone can search exercises
    can [:search, :random_exercise], Exercise

    if !user.global_role.can_edit_system_configuration? &&
      !user.global_role.can_manage_all_courses? &&
      !user.global_role.is_instructor?

      # Still needs revision
      can [:index, :read, :practice, :evaluate], Exercise,
        Exercise.visible_to_user(user) do |e|
        e.visible_to?(user)
      end
      can [:show], WorkoutOffering do |o|
        o.can_be_seen_by? user
#        now = Time.now
#        ((o.opening_date == nil) || (o.opening_date <= now)) &&
#          o.course_offering.course_enrollments.where(user_id: user.id).any?
      end
      can [:practice], WorkoutOffering do |o|
        o.can_be_seen_by? user
#        now = Time.now
#        ((o.opening_date == nil) || (o.opening_date <= now)) &&
#          ((o.hard_deadline >= now) || (o.soft_deadline >= now)) &&
#          o.course_offering.course_enrollments.where(user_id: user.id).any?
      end
      can :practice, Exercise do |e|
        now = Time.now
        e.is_public? || WorkoutOffering.
          joins{workout.exercises}.joins{course_offering.course_enrollments}.
          where{
            course_offering.course_enrollments.user_id == user.id &
            course_offering.course_enrollments.course_role_id.not_eq
              CourseRole.STUDENT_ID
             }.any? || WorkoutOffering.
          joins{workout.exercises}.joins{course_offering.course_enrollments}.
          where{
            ((starts_on == nil) | (starts_on <= now)) &
            course_offering.course_enrollments.user_id == user.id
             }.any?
#        e.workouts.workout_offerings.where(
#          '(starts_on is NULL or starts_on < :time) and ' \
#          '(hard_deadline >= :time or soft_deadline >= :time)',
#          { time: Time.now }).course_offering.course_enrollments.
#          where(user: user)
      end
      can :evaluate, Exercise do |e|
        now = Time.now
        WorkoutOffering.
          joins{workout.exercises}.joins{course_offering.course_enrollments}.
          where{
            ((starts_on == nil) | (starts_on <= now)) &
            ((hard_deadline >= now) | (soft_deadline >= now)) &
            course_offering.course_enrollments.user_id == user.id
             }.any?
#        e.workouts.workout_offerings.where(
#          '(starts_on is NULL or starts_on < :time) and ' \
#          '(hard_deadline >= :time or soft_deadline >= :time)',
#          { time: Time.now }).course_offering.course_enrollments.
#          where(user: user)
      end
      can :create, Exercise if user.global_role.is_instructor?
      can [:update], Exercise, exercise_owners: { owner: user }

      can :read, Attempt, workout_score:
        { workout_offering:
          { course_offering:
            { course_enrollment:
              { user: user, course_role:
                { can_manage_assignments: true } } } } }
      can [:create, :read], Attempt, user: user
    end
  end


  # -------------------------------------------------------------
  def process_workouts(user)
    can [:read, :update, :destroy], Workout, creator_id: user.id
    can :practice, Workout, is_public: true
  end


  # -------------------------------------------------------------
  def process_resource_files(user)
    can [:read, :update, :destroy], ResourceFile, user_id: user.id
  end

end
