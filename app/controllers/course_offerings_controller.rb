class CourseOfferingsController < ApplicationController
  require 'csv'
  before_action :set_course_offering, only: [:show, :edit, :update, :destroy, :generate_gradebook, :add_workout, :store_workout]

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
  
  #
  def generate_gradebook
    respond_to do |format|
      format.csv do
        headers['Content-Disposition']="attachment; filename=\"#{@course_offering.name} Gradebook.csv\""
        headers['Content-Type']||='text-csv'        
      end
    end
  end
  
  # GET /course_offerings/:id/add_workout
  def add_workout
    @workouts=Workout.all
    @wkts=[]
    @course_offering.workouts.each do |wks|
      @wkts<<wks
    end
    @workouts=@workouts-@wkts
    @course_offering    
  end
  
  # POST /course_offerings/store_workout/:id
  def store_workout
    workouts=params[:workoutids]
    workouts.each do |wkid|
      wk=Workout.find(wkid)
      @course_offering.workouts<<wk
      @course_offering.save
      wek = @course_offering.workout_offerings.find_by_sql("select * from workout_offerings where workout_id=#{wkid} and course_offering_id=#{@course_offering.id}")
      wek.last.opening_date=params[:opening_date]
      wek.last.soft_deadline=params[:soft_deadline]
      wek.last.hard_deadline=params[:hard_deadline]
      wek.last.save
    end
    redirect_to course_offering_path(@course_offering), notice: 'Workouts added to course offering!'    
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
