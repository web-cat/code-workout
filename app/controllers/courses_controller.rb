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


  # -------------------------------------------------------------
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
        permit(:name, :id, :number, :organization_id, :term_id)
    end

end
