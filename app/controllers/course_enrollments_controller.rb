class CourseEnrollmentsController < ApplicationController

  def new
    parse_params

    respond_to do |format|
      format.js
    end
  end

  def choose_roster
    parse_params

    respond_to do |format|
      format.js
    end
  end

  def roster_upload
    flash[:notice] = 'This functionality is pending.'
    redirect_to root_path and return
  end

  private

  def parse_params
    @term = Term.find params[:term_id] if params[:term_id]
    @course = Course.find params[:course_id] if params[:course_id]
    @course_offerings = current_user.andand.course_offerings_for_term(@term, @course)
  end
end
