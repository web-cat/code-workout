class CoursesController < ApplicationController
  load_and_authorize_resource
  respond_to :html, :js, :json


  #~ Action methods ...........................................................

  # -------------------------------------------------------------
  # GET /courses
  def index
  end


  # -------------------------------------------------------------
  # GET /courses/1
  def show
    if params[:organization_id]
        @organization = Organization.find(params[:organization_id])
    end
    if !@course
      flash[:warning] = 'Course not found.'
      redirect_to organizations_path
    elsif !params[:term_id]
      render 'show_terms'
    else
      @term = Term.find(params[:term_id])
        
      @course_offerings =
        current_user.andand.course_offerings_for_term(@term, @course)
      @is_student = !user_signed_in? ||
        !current_user.global_role.is_admin? &&
        (@course_offerings.any? {|co| co.is_student? current_user } ||
        !@course_offerings.any? {|co| co.is_staff? current_user })
      # respond_to do |format|
       # format.js
       # format.html
      # end
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
    form = params[:course]
    offering = form[:course_offering]
    @course = Course.find_by(number: form[:number])

    if @course.nil?
      org = Organization.find_by(id: form[:organization_id])
      if !org
        flash[:error] = "Organization #{form[:organization_id]} " +
          'could not be found.'
        redirect_to root_path and return
      end
      @course = Course.new(
        name: form[:name].to_s,
        number: form[:number].to_s,
        creator_id: current_user.id,
        organization: org)
        org.courses << @course
        org.save
    else
      @course.course_offerings do |c|
        if c.term == offering[:term].to_s
          redirect_to new_course_path,
            alert: 'A course offering with this number for this ' +
            'term already exists.' and return
        end
      end
    end

    tmp = CourseOffering.create(
      label: offering[:label].andand.to_s,
      url: offering[:url].andand.to_s,
      self_enrollment_allowed:
        offering[:self_enrollment_allowed].andand.to_i == '1',
      term: Term.find_by(id: offering[:term].andand.to_i))
    @course.course_offerings << tmp

    if @course.save
      redirect_to organization_course_path(
        @course.organization,
        @course,
        tmp.term), notice: "#{tmp.display_name} was successfully created."
    else
      render action: 'new'
    end
  end


  # -------------------------------------------------------------
  # PATCH/PUT /courses/1
  def update
    if @course.update(course_params)
      redirect_to organization_courses_path(
        @course.organization,
        @course),
        notice: "#{@course.display_name} was successfully updated."
    else
      render action: 'edit'
    end
  end

  def student_exercise
    @course = Course.find(params[:id])
    @exercise = Exercise.new
  end

  def add_exercise
    @course = Course.find(params[:id])
    @available_exercises = current_user.available_exercises
    @available_exercises = @available_exercises - @course.exercises
  end
  
  # PATCH /courses/id
  def attach_exercise
    @course = Course.find(params[:id])
    exercise = Exercise.find(params[:course][:course_exercises][:exercise])
    is_instructor = false
    @course.course_offerings.select{|co| co.term.now?}.each do |course_offering|
      is_instructor = true if CourseEnrollment.find_by(user: current_user, course_offering: course_offering).course_role.can_manage_assignments?
    end
    course_ex = CourseExercise.new(course: @course, contributor: current_user, exercise: exercise, curated: is_instructor)
    if course_ex.save 
      redirect_to root_path, notice: 'Exercise added'
    else
      redirect_to root_path, alarm: 'Exercise addition failed'
    end 
  end
  
  def student_course_exercise
    @course = Course.find(params[:id])
  end
  
  # -------------------------------------------------------------
  # DELETE /courses/1
  def destroy
    description = @course.display_name
    if @course.destroy
      redirect_to organization_path(@course.organization),
        notice: "#{description} was successfully destroyed."
    else
      flash[:error] = "Unable to detroy #{description}."
      redirect_to organization_path(@course.organization)
    end
  end

  # --------------------------------------------------------------
  def list_exercises
    @course = Course.find(params[:id])
    @course_exercises = @course.course_exercises 
  end
  
  # --------------------------------------------------------------
  def approve_course_exercise
    @course = Course.find(params[:id])
    @course_exercise = CourseExercise.find(params[:cex_id])
    @course_exercise.curated = true
    @course_exercise.exercise.is_public = true
    @course_exercise.exercise.owners << current_user
    @course_exercise.exercise.save
    if @course_exercise.save
      redirect_to root_path, notice: 'Exercise approved'
    else
      redirect_to root_path, notice: 'Exercise approval failed'
    end
  end
  
  # --------------------------------------------------------------
  def remove_course_exercise
    @course_exercise = CourseExercise.find(params[:cex_id])
    if @course_exercise.destroy
      redirect_to root_path, notice: 'Exercise removed'
    else
      redirect_to root_path, notice: 'Exercise removal failed'
    end
  end
  # --------------------------------------------------------------
  def search
  end


  # -------------------------------------------------------------
  def find
    @courses = Course.search(params[:search])
    redirect_to courses_search_path(courses: @courses, listing: true),
      format: :js, remote: true
  end


  # -------------------------------------------------------------
  # POST /courses/:id/generate_gradebook
  def generate_gradebook
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
        permit(:name, :id, :number, :organization_id, :term_id, :course_exercises)
    end

end
