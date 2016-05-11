class CourseOfferingsController < ApplicationController
  before_filter :rename_course_offering_id_param
  load_and_authorize_resource


  # -------------------------------------------------------------
  # GET /course_offerings
  def index
  end


  # -------------------------------------------------------------
  # GET /course_offerings/1
  def show
  end


  # -------------------------------------------------------------
  # GET /course_offerings/new
  def new
  end


  # -------------------------------------------------------------
  # GET /course_offerings/1/edit
  def edit
    @uploaded_roster = UploadedRoster.new
  end


  # -------------------------------------------------------------
  # POST /course_offerings
  def create
    @course_offering = CourseOffering.new(course_offering_params)

    if @course_offering.save
      redirect_to organization_course_path(
        @course_offering.course.organization,
        @course_offering.course,
        @course_offering.term),
        notice: "#{@course_offering.display_name} was successfully created."
    else
      render action: 'new'
    end
  end


  # -------------------------------------------------------------
  # POST /course_enrollments
  # Public: Creates a new course enrollment based on enroll link.
  # FIXME:  Not really sure this is the best place to do it.

  def enroll
    if @course_offering &&
      @course_offering.can_enroll? &&
      CourseEnrollment.create(
      course_offering: @course_offering,
      user: current_user,
      course_role: CourseRole.student)

      redirect_to organization_course_path(
        @course_offering.course.organization,
        @course_offering.course,
        @course_offering.term),
        notice: 'You are now enrolled in ' +
          "#{@course_offering.display_name}."
    else
      flash[:warning] = 'Unable to enroll in that course.'
      redirect_to root_path
    end
  end


  # -------------------------------------------------------------
  # DELETE /unenroll
  # Public: Deletes an enrollment, if it exists.
  def unenroll
    if @course_offering
      path = organization_course_path(
        @course_offering.course.organization,
         @course_offering.course,
        @course_offering.term)
      description = @course_offering.display_name

      @course_offering.course_enrollments.where(user: current_user).destroy_all
      redirect_to path, notice: "You have unenrolled from #{description}."
    else
      flash[:error] =
        'No course offering was specified in your unenroll request.'
      redirect_to root_path
    end
  end
  
  # -------------------------------------------------------------
  # GET /course_offerings/:id/upload_roster
  # Method to enroll students from an uploaded roster.
  # TODO: Needs to be redone so that it will read an actual CSV
  #       file of student enrollment info and not just a list of
  #       e-mail addresses.
  
  def upload_roster
    form_contents = params[:form]
    puts form_contents.fetch(:rosterfile).path
    CSV.foreach(form_contents.fetch(:rosterfile).path) do |enroller|
      student = User.find_by!(email: enroller)
      co = CourseEnrollment.new(user: student, course_offering_id: params[:id], course_role_id: 3)
      co.save!
    end
    redirect_to root_path
  end


  # -------------------------------------------------------------
  # PATCH/PUT /course_offerings/1
  def update
    if @course_offering.update(course_offering_params)
      redirect_to organization_course_path(
        @course_offering.course.organization,
        @course_offering.course,
        @course_offering.term),
        notice: "#{@course_offering.display_name} was successfully updated."
    else
      render action: 'edit'
    end
  end


  # -------------------------------------------------------------
  # DELETE /course_offerings/1
  def destroy
    description = @course_offering.display_name
    path = organization_course_path(
      @course_offering.course.organization,
      @course_offering.course,
      @course_offering.term)
    if @course_offering.destroy
      redirect_to path,
        notice: "#{description} was successfully destroyed."
    else
      flash[:error] = "Unable to destroy #{description}."
      redirect_to path
    end
  end


  # -------------------------------------------------------------
  def generate_gradebook
    @course_enrolled = CourseEnrollment.where(course_offering: @course_offering).
                         sort_by{|ce| [ce.user.last_name.to_s.downcase, ce.user.first_name.to_s.downcase, ce.user.email]}
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
    def rename_course_offering_id_param
      if params[:course_offering_id] && !params[:id]
        params[:id] = params[:course_offering_id]
      end
    end


    # -------------------------------------------------------------
    # Only allow a trusted parameter "white list" through.
    def course_offering_params
      params.require(:course_offering).permit(:course_id, :term_id,
        :label, :url, :self_enrollment_allowed)
    end
end
