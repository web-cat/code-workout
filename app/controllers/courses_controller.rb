class CoursesController < ApplicationController
  before_action :set_course,
    only: [:show, :edit, :generate_gradebook, :update, :destroy]
  respond_to :html, :js, :json


  #~ Action methods ...........................................................

  # -------------------------------------------------------------
  # GET /courses
  def index
    @courses = Course.all
  end


  # -------------------------------------------------------------
  # GET /courses/1
  def show
    respond_to do |format|
      format.js
      format.html
    end
  end


  # -------------------------------------------------------------
  # GET /courses/new
  def new
    if cannot? :new, Course
      redirect_to root_path,
        notice: 'Unauthorized to create new course' and return
    end
    @course = Course.new
  end


  # -------------------------------------------------------------
  # GET /courses/1/edit
  def edit
    if cannot? :edit, @course
      redirect_to root_path,
        notice: 'Unauthorized to edit course' and return
    end
  end


  # -------------------------------------------------------------
  # POST /courses
  def create
    if cannot? :create, Course
      redirect_to root_path,
        notice: 'Unauthorized to create course' and return
    end
    form = params[:course]
    offering = form[:course_offering]
    @course = Course.find_by number: form[:number]

    if @course.nil?
      @course = Course.new
      @course.name = form[:name].to_s
      @course.number = form[:number].to_s
      @course.creator_id = current_user.id
      #@course.save

      #establish relationships
      org = Organization.find_by_id(form[:organization_id])

      if org
        org.courses << @course
        org.save
      end
    else
      @course.course_offerings do |c|
        if c.term == offering[:term].to_s
          redirect_to new_course_path,
            alert: 'A course offering with this number for this ' +
            'term already exists.' and return
        end
      end
    end

    tmp = CourseOffering.create
    tmp.name = form[:name].to_s
    tmp.label = offering[:label].andand.to_s
    tmp.url = offering[:url].andand.to_s
    tmp.self_enrollment_allowed =
      offering[:self_enrollment_allowed].andand. == '1'
    tmp.term_id = offering[:term].andand.to_i
    p tmp.term_id
    @course.course_offerings << tmp

    @course.save
    # TODO: why are there two calls to save in a row here?
    if @course.save!
      redirect_to @course, notice: 'Course was successfully created.'
    else
      render action: 'new'
    end
  end


  # -------------------------------------------------------------
  # PATCH/PUT /courses/1
  def update
    if cannot? :update, @course
      redirect_to root_path,
        notice: 'Unauthorized to update course' and return
    end
    if @course.update(course_params)
      redirect_to @course, notice: 'Course was successfully updated.'
    else
      render action: 'edit'
    end
  end


  # -------------------------------------------------------------
  # DELETE /courses/1
  def destroy
    if cannot? :destroy, @course
      redirect_to root_path,
        notice: 'Unauthorized to delete course' and return
    end
    @course.destroy
    redirect_to courses_url, notice: 'Course was successfully destroyed.'
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
    if cannot? :generate_gradebook, @course
      redirect_to root_path,
        notice: 'Unauthorized to generate gradebook for course' and return
    end
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
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find_by_id(params[:id])
    end


    # -------------------------------------------------------------
    # Only allow a trusted parameter "white list" through.
    def course_params
      params.require(:course).
        permit(:name, :number, :organization_id)
    end

end
