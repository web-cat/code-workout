class CourseOfferingsController < ApplicationController
  before_action :set_course_offering, only: [:show, :edit, :update, :destroy]

  # GET /course_offerings
  def index
    @course_offerings = CourseOffering.all
  end

  # GET /course_offerings/1
  def show
  end

  # GET /course_offerings/new
  def new
    @course_offering = CourseOffering.new
  end

  # GET /course_offerings/1/edit
  def edit
    set_course_offering
    @uploaded_roster = UploadedRoster.new
  end

  # POST /course_offerings
  def create
    @course_offering = CourseOffering.new(course_offering_params)

    if @course_offering.save
      redirect_to @course_offering, notice: 'Course offering was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /course_offerings/1
  def update
    if @course_offering.update(course_offering_params)
      redirect_to @course_offering, notice: 'Course offering was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /course_offerings/1
  def destroy
    @course_offering.destroy
    redirect_to course_offerings_url, notice: 'Course offering was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course_offering
      @course_offering = CourseOffering.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def course_offering_params
      params.require(:course_offering).permit(:course_id, :term_id, :name, :label, :url, :organization_id, :self_enrollment_allowed)
    end
end
