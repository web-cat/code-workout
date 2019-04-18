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
    can [:index, :search, :random_exercise, :gym_practice, :evaluate], Exercise do |e|
      e.is_publicly_available?
    end
    can [:practice, :read], Workout, is_public: true

    # Permissions for reviewing access requests are handled in the
    # controller action itself, since this action will typically be triggered
    # from links in emails.
    can :review_access_request, UserGroup

    can :remote_create, CourseOffering

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

        can :new_or_existing, Organization

        process_global_role user
        process_instructor user
        process_courses user
        process_user_groups user
        process_exercises user
        process_workouts user
        process_workout_offerings user
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
        UserGroup,
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
      can [:manage], [Course, CourseOffering, CourseEnrollment,
        Exercise, Attempt, ResourceFile]

      #can [:index], [Workout, Exercise, Attempt, ResourceFile]
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

      can :add_workout, CourseOffering

      # A user can manage a CourseOffering if they are enrolled in that
      # offering and have a CourseRole where can_manage_course? is true.
      # can [:manage], CourseOffering,
      #   CourseOffering.managed_by_user(user) do |co|
      #   co.is_manager? user
      # end
      can :create, [CourseOffering, Course, Organization]
      can :manage, CourseOffering, course_enrollments:
        { user_id: user.id, course_role:
          { can_manage_assignments: true} }

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

      # A user can request tab content on the course page through AJAX if they are 
      # enrolled in an offering of the course
      can :tab_content, Course do |course|
        course.course_offerings.any? { |co| co.is_enrolled? (user) }
      end

      # A user can view and edit a course's privileged users if they are also a privileged user
      can :privileged_users, Course do |course|
        course.creator_id == user.id || user.is_a_member_of?(course.user_group)
      end

      can :request_privileged_access, Course do |course|
        user.global_role.is_admin? ||
        (
          !user.is_a_member_of?(course.user_group) &&
          user.access_request_for(course.user_group).nil? &&
          course.course_offerings.any?{ |co| co.is_instructor? user }
        )
      end

      # A user can search for courses if they are signed in
      can :search, Course
    end
  end

  # -------------------------------------------------------------
  def process_user_groups(user)
    can :create, UserGroup
    can [ :members, :add_user ], UserGroup do |group|
      user.is_a_member_of?(group) || user.global_role.is_admin?
    end
  end

  # -------------------------------------------------------------
  def process_exercises(user)
    # Everyone can search exercises
    can [:search, :random_exercise], Exercise

    if !user.global_role.can_edit_system_configuration? &&
      !user.global_role.can_manage_all_courses? &&
      !user.global_role.is_instructor?

      can [:read, :evaluate], Exercise do |e|
        e.visible_to?(user)
      end

      can :practice, Exercise do |e|
        now = Time.now
        e.visible_to?(user) || WorkoutOffering.
          joins{workout.exercises}.joins{course_offering.course_enrollments}.
          where{
            ((starts_on == nil) | (starts_on <= now)) &
            course_offering.course_enrollments.user_id == user.id
             }.any?
      end

      can [ :gym_practice, :embed ], Exercise do |e|
        e.visible_to?(user)
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
      end
      # can :create, Exercise if user.global_role.is_instructor?
      # can :edit, Exercise do |e|
      #   created = user == e.current_version.andand.creator
      #   user_in_group = user.is_a_member_of?(e.exercise_collection.andand.user_group)
      #   owns_collection = user == e.exercise_collection.andand.user

      #   created || user_in_group || owns_collection
      # end

      can :read, Attempt, workout_score:
        { workout_offering:
          { course_offering:
            { course_enrollments:
              { user_id: user.id, course_role:
                { can_manage_assignments: true } } } } }
      can [:create, :read], Attempt, user_id: user.id

      can :query_data, Exercise
      can :download_attempt_data, Exercise do |e|
        e.owned_by?(user)
      end
    end
  end


  # -------------------------------------------------------------
  def process_workouts(user)
    can [:read, :update, :destroy], Workout, creator_id: user.id
    can :create, Workout if user.instructor_course_offerings.any?
    can :update, Workout do |w|
      user.managed_workouts.include?(w) || w.creator_id = user.id
    end

    # This doesn't affect WorkoutOffering permissions, which are based on enrollments
    # due dates, and publishing dates.
    # The workout offering practice and show actions check their own permissions
    # and use the Workout VIEWS, not controller actions.
    # So this permission affects ONLY gym access.
    can [:read, :practice, :embed], Workout, is_public: true
    can :clone, Workout
  end

  def process_workout_offerings(user)
    can :create, WorkoutOffering if user.instructor_course_offerings.any?
    can [:show, :practice], WorkoutOffering do |o|
      o.can_be_seen_by? user
    end

    can :manage, WorkoutOffering, course_offering:
      { course_enrollments:
        { user_id: user.id, course_role:
          { can_manage_assignments: true } } }
  end

  # -------------------------------------------------------------
  def process_resource_files(user)
    can [:read, :update, :destroy], ResourceFile, user_id: user.id
  end
end
