class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :generate_gradebook,:update, :destroy]

  # GET /courses
  def index
    @courses = Course.all
  end

  # GET /courses/1
  def show
    respond_to do |format|
      format.js
      format.html      
    end
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
    
    form = params[:course]
    @course = Course.find_by number: form[:number]
    if @course.nil?
      @course = Course.new
      @course.name = form[:name].to_s
      @course.number = form[:number].to_s
      #@course.save
    
      #establish relationships
      org = Organization.find(form[:organization_id])
    
      unless org.nil?
        org.courses << @course
        org.save
      end
     else
       @course.each do |c|
         if c.term == offering[:term].to_s
           redirect_to new_course_path, alert: 'Course offering with this number for this term already exists' and return
         end
       end
     end
      offering=form[:course_offering]
      tmp = CourseOffering.create
      tmp.name = form[:name].to_s
      unless offering[:label].nil?
        tmp.label = offering[:label].to_s
      end
      unless offering[:url].nil?
        tmp.url = offering[:url].to_s
      end
      unless offering[:self_enrollment_allowed].nil?
        tmp.self_enrollment_allowed = offering[:self_enrollment_allowed] == "1"
      end
      unless offering[:term].nil?
        tmp.term_id = offering[:term].to_i
        p tmp.term_id
      end
      @course.course_offerings << tmp
    
      @course.save

    if @course.save!
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
  
  # POST /courses/:id/generate_gradebook
  def generate_gradebook
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition']="attachment; filename=\"#{@course.name} course gradebook.csv\""
        headers['Content-Type']||="text-csv"
      end
    end
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
