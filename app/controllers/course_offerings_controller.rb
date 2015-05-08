class CourseOfferingsController < ApplicationController
  before_action :set_course_offering, only: [:show, :edit, :update,
    :destroy, :generate_gradebook, :add_workout, :store_workout]


  # -------------------------------------------------------------
  # GET /course_offerings
  def index
    @course_offerings = CourseOffering.all
  end


  # -------------------------------------------------------------
  # GET /course_offerings/1
  def show
  end


  # -------------------------------------------------------------
  # GET /course_offerings/new
  def new
    if cannot? :new, CourseOffering
      redirect_to root_path,
        notice: 'Unauthorized to create course offering' and return
    end
    @course_offering = CourseOffering.new
  end


  # -------------------------------------------------------------
  # GET /course_offerings/1/edit
  def edit
    set_course_offering
    if cannot? :edit, @course_offering
      redirect_to root_path,
        notice: 'Unauthorized to edit course offering' and return
    end
    @uploaded_roster = UploadedRoster.new
  end


  # -------------------------------------------------------------
  # POST /course_offerings
  def create
    if cannot? :create, CourseOffering
      redirect_to root_path,
        notice: 'Unauthorized to create course offering' and return
    end
    @course_offering = CourseOffering.new(course_offering_params)
  # Sets a default cutoff_date for an offering if there isn't already one.
  # TODO: Need to implement this available from the view    
    @course_offering.cutoff_date = @course_offering.cutoff_date || term.ends_on    
    
    if @course_offering.save
      redirect_to @course_offering,
        notice: 'Course offering was successfully created.'
    else
      render action: 'new'
    end
  end
  
  # -------------------------------------------------------------
  # POST /course_enrollments
  # Public: Creates a new course enrollment based on enroll link.
  # FIXME:  Not really sure this is the best place to do it.
  
  def create_enrollment    
    @course_enrollment = CourseEnrollment.new(course_enrollment_params)
    if @course_enrollment.save
      redirect_to root_path,
        notice: 'Course enrollment was successfully created.'
    else
      redirect_to root_path,
        notice: 'Enrollment didnt really work.'
    end
  end

  # -------------------------------------------------------------
  # DELETE /unenroll
  # Public: Deletes an enrollment, if it exists.
  # FIXME:  Not really sure this is the best place to do it.
  def delete_enrollment
    CourseEnrollment.where(user_id: course_enrollment_params[:user_id]).
       where(course_offering_id: course_enrollment_params[:course_offering_id]).
       delete_all
    redirect_to root_path, notice: "You enrollment has been removed"
  end

  # -------------------------------------------------------------
  # PATCH/PUT /course_offerings/1
  def update
    if cannot? :update, @course_offering
      redirect_to root_path,
        notice: 'Unauthorized to edit course offering' and return
    end
    if @course_offering.update(course_offering_params)
      redirect_to @course_offering,
        notice: 'Course offering was successfully updated.'
    else
      render action: 'edit'
    end
  end


  # -------------------------------------------------------------
  # DELETE /course_offerings/1
  def destroy
    if cannot? :destroy, @course_offering
      redirect_to root_path,
        notice: 'Unauthorized to destroy course offering' and return
    end
    @course_offering.destroy
    redirect_to course_offerings_url,
      notice: 'Course offering was successfully destroyed.'
  end


  # -------------------------------------------------------------
  def generate_gradebook
    if cannot? :generate_gradebook, @course_offering
      redirect_to root_path,
        notice: 'Unauthorized to generate gradebook for course offering' and
        return
    end
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] =
          "attachment; filename=\"#{@course_offering.course.number}-" \
          "#{@course_offering.label}-Gradebook.csv\""
        headers['Content-Type'] ||= 'text-csv'
      end
    end
  end


  # -------------------------------------------------------------
  # GET /course_offerings/:id/add_workout
  def add_workout
    if cannot? :add_workout, @course_offering
      redirect_to root_path,
        notice: 'Unauthorized to add workout for course offering' and return
    end
    @workouts = Workout.all
    @wkts = []
    @course_offering.workouts.each do |wks|
      @wkts << wks
    end
    @workouts = @workouts - @wkts
    @course_offering
  end


  # -------------------------------------------------------------
  # POST /course_offerings/store_workout/:id
  def store_workout
    workouts = params[:workoutids]
    workouts.each do |wkid|
      wk = Workout.find(wkid)
      @course_offering.workouts << wk
      @course_offering.save
      wek = @course_offering.workout_offerings.where(workout_id: wkid)
      wek.last.opening_date = params[:opening_date]
      wek.last.soft_deadline = params[:soft_deadline]
      wek.last.hard_deadline = params[:hard_deadline]
      wek.last.save
    end
    redirect_to course_offering_path(@course_offering),
      notice: 'Workouts added to course offering!'
  end


  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    # Use callbacks to share common setup or constraints between actions.
    def set_course_offering
      @course_offering = CourseOffering.find(params[:id])
    end


    # -------------------------------------------------------------
    # Only allow a trusted parameter "white list" through.
    def course_offering_params
      params.require(:course_offering).permit(:course_id, :term_id,
        :label, :url, :self_enrollment_allowed)
    end
    # -------------------------------------------------------------
    # FIXME: Hacky workaround to get in the parameters for 
    # course enrollment since its controller is gone!    
    def course_enrollment_params
      params.require(:course_enrollment).permit(:course_offering_id,
        :course_role_id, :user_id)
    end
end
