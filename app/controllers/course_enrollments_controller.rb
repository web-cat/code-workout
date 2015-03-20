class CourseEnrollmentsController < ApplicationController
  before_action :set_course_enrollment, only: [:show, :edit, :update, :destroy]

  # GET /course_enrollments
  def index
    if cannot? :index, CourseEnrollment
      print "CANNOT ACCESS"
      redirect_to root_path, notice: 'Unauthorized to view course enrollments' and return
    end
    print "CAN ACCESS"
    @course_enrollments = CourseEnrollment.all
  end

  # GET /course_enrollments/1
  def show
    if cannot? :show, @course_enrollment
      redirect_to root_path, notice: 'Unauthorized to view course enrollment' and return
    end
    @role_text =  CourseRole.find(@course_enrollment.course_role_id).name
  end

  # GET /course_enrollments/new
  def new
    if cannot? :new, CourseEnrollment || !user_signed_in? 
      redirect_to root_path, notice: 'Unauthorized to create course enrollments' and return
    else
      @course_enrollment = CourseEnrollment.new
    end
  end

  # GET /course_enrollments/1/edit
  def edit
    if cannot? :edit, CourseEnrollment || !user_signed_in?
      redirect_to root_path, notice: 'Unauthorized to edit course enrollments' and return
    end
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
    if cannot? :update, CourseEnrollment || !user_signed_in? 
      redirect_to root_path, notice: 'Unauthorized to update course enrollments' and return
    end
    if @course_enrollment.update(course_enrollment_params)
      redirect_to @course_enrollment, notice: 'Course enrollment was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /course_enrollments/1
  def destroy
    if cannot? :create, CourseEnrollment || !user_signed_in?
      redirect_to root_path, notice: 'Unauthorized to create course enrollments' and return
    end
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
      params.require(:course_enrollment).permit(:user_id, :course_offering_id, :course_role_id)
    end
end
