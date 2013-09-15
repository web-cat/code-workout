class CourseRolesController < ApplicationController
  before_action :set_course_role, only: [:show, :edit, :update, :destroy]

  # GET /course_roles
  def index
    @course_roles = CourseRole.all
  end

  # GET /course_roles/1
  def show
  end

  # GET /course_roles/new
  def new
    @course_role = CourseRole.new
  end

  # GET /course_roles/1/edit
  def edit
  end

  # POST /course_roles
  def create
    @course_role = CourseRole.new(course_role_params)

    if @course_role.save
      redirect_to @course_role,
        notice: 'Course role was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /course_roles/1
  def update
    if @course_role.update(course_role_params)
      redirect_to @course_role,
        notice: 'Course role was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /course_roles/1
  def destroy
    @course_role.destroy
    redirect_to course_roles_url,
      notice: 'Course role was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course_role
      @course_role = CourseRole.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def course_role_params
      params.require(:course_role).permit(
        :name,
        :can_manage_course,
        :can_manage_assignments,
        :can_grade_submissions,
        :can_view_other_submissions)
    end
end
