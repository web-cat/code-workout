class CoursesController < ApplicationController
  # load_and_authorize_resource
  respond_to :html, :js, :json


  #~ Action methods ...........................................................

  # -------------------------------------------------------------
  # GET /courses
  def index
  end


  # -------------------------------------------------------------
  # GET /courses/:organization_id/:id/(:term_id)
  def show
    if params[:organization_id]
        @organization = Organization.find(params[:organization_id])
    end
    @course = Course.find_with_id_or_slug(params[:id], @organization)
    authorize! :show, @course
    if !@course
      flash[:warning] = 'Course not found.'
      redirect_to organizations_path
    elsif !params[:term_id]
      render 'show_terms'
    else
      @term = Term.find(params[:term_id])
      @course_offerings =
        current_user.andand.course_offerings_for_term(@term, @course)
      if @course_offerings.present? && @course_offerings.respond_to?(:includes)
        @course_offerings = @course_offerings.includes(
          :course,
          :term,
          course_enrollments: [:user, :course_role],
          workout_offerings: [
            :workout_policy,
            :student_extensions,
            workout: :exercise_workouts
          ]
        )
      end
      @course_offering = @course_offerings.andand.first
      if current_user
        @is_instructor = current_user.global_role.is_admin? ||
          @course_offerings.any? { |co| co.is_instructor? current_user }
        @is_student = !@is_instructor

        if @course_offerings.present?
          workout_offering_ids = @course_offerings.flat_map(&:workout_offering_ids).uniq
          if workout_offering_ids.any?
            @workout_scores_by_offering_id = WorkoutScore.where(
              workout_offering_id: workout_offering_ids,
              user_id: current_user.id
            ).group_by(&:workout_offering_id)
            @workout_scores_by_workout_id = WorkoutScore.where(
              workout_offering_id: workout_offering_ids,
              user_id: current_user.id
            ).group_by(&:workout_id)
          end
        end
      end
      @is_privileged = current_user.andand.is_a_member_of?(@course.user_group)
      @access_request = current_user.andand.access_request_for(@course.user_group)
    end
  end

  # /courses/:organization_id/:id/privileged_users
  def privileged_users
    @course = Course.find_with_id_or_slug(
      params[:id], params[:organization_id]
    )
    authorize! :privileged_users, @course
    @user_group = @course.user_group
    memberships = @user_group.andand.memberships.andand.order(created_at: :desc)
    @users = memberships.andand.map(&:user)

    respond_to do |format|
      format.json { render json: @users.to_json }
      format.html
    end
  end

  # -------------------------------------------------------------
  # GET /courses/:organization_id/:id/request_privileged_access/:user
  def request_privileged_access
    @requester = User.find params[:requester_id]
    @course = Course.find_with_id_or_slug(
      params[:id], params[:organization_id]
    )
    authorize! :request_privileged_access, @course
    @user_group = @course.user_group
    if @user_group.nil?
      @user_group = UserGroup.new(
        user_group: @course.number,
        description: "Privileged Users for #{@course.display_name}."
      )
      @user_group.course = @course
      @user_group.save
    end

    if @requester.access_request_for(@user_group).nil?
      @access_request = GroupAccessRequest.new(
        user: @requester,
        user_group: @user_group
      )
      @access_request.save

      @users = (@user_group.users + User.where(global_role_id: GlobalRole.administrator)).uniq

      @users.each do |user|
        UserGroupMailer.review_access_request(user, @access_request, @course).deliver
      end

      allowed = true
    else
      allowed = false
    end

    respond_to do |format|
      format.js
      format.html {
        if (!allowed)
          flash[:error] = 'You cannot make a second request for access to that course.'
          redirect_to root_path
        else
          redirect_to root_path
        end
      }
    end
  end

  # -------------------------------------------------------------
  # GET /courses/:organization_id/:course_id/:term_id/tab_content/:tab
  def tab_content
    @organization = Organization.find params[:organization_id]
    @course = Course.find_with_id_or_slug(
      params[:course_id], params[:organization_id]
    )
    authorize! :tab_content, @course
    @term = Term.find params[:term_id]
    @tab = params[:tab]

    @course_offerings = current_user.andand.course_offerings_for_term(@term, @course)
    @is_student = !user_signed_in? ||
      !current_user.global_role.is_admin? &&
      (@course_offerings.any? { |co| co.is_student? current_user } ||
      !@course_offerings.any? { |co| co.is_staff? current_user })

    if @course_offerings.present?
      case @tab
      when 'tab_workouts'
        if @course_offerings.respond_to?(:includes)
          @course_offerings = @course_offerings.includes(
            :course,
            :term,
            course_enrollments: [:user, :course_role],
            workout_offerings: [
              :workout_policy,
              :student_extensions,
              workout: :exercise_workouts
            ]
          )
        end
        if current_user
          workout_offering_ids = @course_offerings.flat_map(&:workout_offering_ids).uniq
          if workout_offering_ids.any?
            @workout_scores_by_offering_id = WorkoutScore.where(
              workout_offering_id: workout_offering_ids,
              user_id: current_user.id
            ).group_by(&:workout_offering_id)
            @workout_scores_by_workout_id = WorkoutScore.where(
              workout_offering_id: workout_offering_ids,
              user_id: current_user.id
            ).group_by(&:workout_id)
          end
        end
      when 'tab_grades'
        if @course_offerings.respond_to?(:includes)
          @course_offerings = @course_offerings.includes(
            :course,
            :term,
            course_enrollments: [:user, :course_role],
            workout_offerings: [
              :workout_policy,
              workout: :exercise_workouts
            ]
          )
        end
        workout_offering_ids = @course_offerings.flat_map(&:workout_offering_ids).uniq
        if @is_student
          if current_user && workout_offering_ids.any?
            @workout_scores_by_offering_id = WorkoutScore.where(
              workout_offering_id: workout_offering_ids,
              user_id: current_user.id
            ).group_by(&:workout_offering_id)
          end
        else
          # Instructor view: load scores for all students across offerings in 1 batch query
          student_ids = @course_offerings.flat_map do |co|
            co.course_enrollments.select { |ce| ce.course_role_id == CourseRole::STUDENT_ID }.map(&:user_id)
          end.uniq
          if workout_offering_ids.any? && student_ids.any?
            @workout_scores_by_offering_and_user = WorkoutScore.where(
              workout_offering_id: workout_offering_ids,
              user_id: student_ids
            ).order('updated_at DESC').group_by { |ws| [ws.workout_offering_id, ws.user_id] }
          else
            @workout_scores_by_offering_and_user = {}
          end
        end
      when 'tab_roster'
        if @course_offerings.respond_to?(:includes)
          @course_offerings = @course_offerings.includes(
            course_enrollments: [:user, :course_role]
          )
        end
      when 'tab_exercises'
        @exercises = @course.exercises.includes(:exercise_family, :current_version)
      end
    end

    if @course_offerings.respond_to?(:includes)
      if @tab == 'tab_grades'
        @course_offerings = @course_offerings.includes(
          course_enrollments: [:user, :course_role],
          workout_offerings: [:workout, :workout_policy, :workout_scores]
        )
      elsif @tab == 'tab_roster'
        @course_offerings = @course_offerings.includes(
          course_enrollments: [:user, :course_role]
        )
      elsif @tab == 'tab_workouts'
        @course_offerings = @course_offerings.includes(
          workout_offerings: [:workout, :workout_policy]
        )
      end
    end

    respond_to do |format|
      format.js
    end
  end

  # -------------------------------------------------------------
  # GET /courses/new
  def new
    @course = Course.new
  end


  # -------------------------------------------------------------
  # GET /courses/1/edit
  def edit
  end


  # -------------------------------------------------------------
  # POST /courses
  def create
    create_params = params[:course]
    @organization = Organization.find(params[:organization_id])
    @course = Course.new(
      name: create_params[:name],
      number: create_params[:number],
      slug: create_params[:slug],
      organization: @organization,
      is_hidden: create_params[:is_hidden]
    )

    if @course.save
      group = UserGroup.create(
        name: @course.number,
        course: @course,
        description: "Privileged users for #{@course.display_name}."
      )

      group.add_user_to_group(current_user)

      url = url_for(organization_new_course_offering_path(
          course_id: @course.id,
          organization_id: @organization.id,
          new_course: true
        )
      )
      render json: { success: true, url: url } and return
    else
      render json: { success: false, error:
        "There was a problem while creating your course. Please check your fields and try again." } and return
    end
  end


  # -------------------------------------------------------------
  # PATCH/PUT /courses/1
  def update
    @course = Course.find params[:id]
    if @course.update(course_params)
      redirect_to organization_courses_path(
        @course.organization,
        @course),
        notice: "#{@course.display_name} was successfully updated."
    else
      render action: 'edit'
    end
  end


  # -------------------------------------------------------------
  # DELETE /courses/1
  def destroy
    @course = Course.find_with_id_or_slug(params[:id])
    description = @course.display_name
    if @course.destroy
      redirect_to organization_path(@course.organization),
        notice: "#{description} was successfully destroyed."
    else
      flash[:error] = "Unable to detroy #{description}."
      redirect_to organization_path(@course.organization)
    end
  end


  # -------------------------------------------------------------
  def search
    @organization = Organization.find params[:organization_id]
    if params[:term] && params[:slug]
      @courses = Course.find_by(organization: @organization, slug: params[:term])
    elsif params[:term]
      @courses = @organization.courses.where('lower(name) like ? or lower(number) like ? or slug like ?',
        "%#{params[:term].downcase}%", "%#{params[:term].downcase}%", "%#{params[:term]}%")
    else
      @courses = @organization.courses
    end

    render json: @courses and return
  end


  # -------------------------------------------------------------
  # TODO: Not certain what this method achieves (also not sure about 'Course.search')
  def find
    @courses = Course.search(params[:search])
    redirect_to courses_search_path(courses: @courses, listing: true),
      format: :js, remote: true
  end


  # -------------------------------------------------------------
  # POST /courses/:organization_id/:id/:term_id/generate_gradebook
  def generate_gradebook
    @course = Course.find_with_id_or_slug(params[:id], params[:organization_id])
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] =
          "attachment; filename=\"#{@course.name} course gradebook.csv\""
        headers['Content-Type'] ||= 'text-csv'
      end
    end
  end


  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    # Only allow a trusted parameter "white list" through.
    def course_params
      params.require(:course).
        permit(:name, :id, :number, :organization_id, :term_id)
    end

end
