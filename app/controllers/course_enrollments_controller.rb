class CourseEnrollmentsController < ApplicationController
  before_action :set_course_enrollment, only: [:show, :edit, :update, :destroy]

  # GET /course_enrollments
  def index
    @course_enrollments = CourseEnrollment.all
  end

  # GET /course_enrollments/1
  def show
  end

  # GET /course_enrollments/new
  def new
    @course_enrollment = CourseEnrollment.new
  end

  # GET /course_enrollments/1/edit
  def edit
  end

  # POST /course_enrollments
  def create
    @course_enrollment = CourseEnrollment.new(course_enrollment_params)

    if @course_enrollment.save
      redirect_to @course_enrollment, notice: 'Course enrollment was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /course_enrollments/1
  def update
    if @course_enrollment.update(course_enrollment_params)
      redirect_to @course_enrollment, notice: 'Course enrollment was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /course_enrollments/1
  def destroy
    @course_enrollment.destroy
    redirect_to course_enrollments_url, notice: 'Course enrollment was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course_enrollment
      @course_enrollment = CourseEnrollment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def course_enrollment_params
      params.require(:course_enrollment).permit(:user, :course_offering, :course_role)
    end
end
