class CourseEnrollmentsController < ApplicationController

  def new
    @term = Term.find params[:term_id] if params[:term_id]
    @course = Course.find params[:course_id] if params[:course_id]
    @course_offerings = current_user.andand.course_offerings_for_term(@term, @course)

    respond_to do |format|
      format.js
    end
  end
end
