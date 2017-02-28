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
  # GET /courses/vt/:course_id/:term_id
  def tab_content
    @course = Course.find params[:course_id]
    @term = Term.find params[:term_id]
    @course_offerings = current_user.andand.course_offerings_for_term(@term, @course)
    @is_student = !user_signed_in? ||
      !current_user.global_role.is_admin? &&
      (@course_offerings.any? {|co| co.is_student? current_user } ||
      !@course_offerings.any? {|co| co.is_staff? current_user })
    @tab = params[:tab]

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
      organization: @organization
    )

    if @course.save
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
