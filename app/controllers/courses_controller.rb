class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  # GET /courses
  def index
    @courses = Course.all
  end

  # GET /courses/1
  def show
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses
  def create
    @course = Course.new
    form = params[:course]
    @course.name = form[:name].to_s
    @course.number = form[:number].to_s
    @course.save

    #establish relationships
    org = Organization.find(form[:organization_id])
    unless org.nil?
      org.courses << @course
      org.save
    end
    form[:course_offerings_attributes].each do |offering|
      tmp = CourseOffering.create
      tmp.name = offering.second[:name].to_s
      unless offering.second[:label].nil?
        tmp.label = offering.second[:label].to_s
      end
      unless offering.second[:url].nil?
        tmp.url = offering.second[:url].to_s
      end
      unless offering.second[:self_enrollment_allowed].nil?
        tmp.self_enrollment_allowed = offering.second[:self_enrollment_allowed] == "1"
      end
      unless offering.second[:term_id].nil?
        tmp.term_id = offering.second[:term_id]
      end
      tmp.save
      @course.course_offerings << tmp
    end
    @course.save!

    if @course.save
      redirect_to @course, notice: 'Course was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /courses/1
  def update
    if @course.update(course_params)
      redirect_to @course, notice: 'Course was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /courses/1
  def destroy
    @course.destroy
    redirect_to courses_url, notice: 'Course was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def course_params
      params.require(:course).permit(:name, :number, :organization_id, :url_part)
    end
end
