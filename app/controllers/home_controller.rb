class HomeController < ApplicationController
  layout 'application', except: [:index]
  respond_to :html, except: [:new_course_modal, :python_ruby_modal]
  respond_to :js, only: [:new_course_modal, :python_ruby_modal]

  def index
    if params[:notice]
      flash.now[:notice] = params[:notice]
    end
  end

  def about
  end

  def license
  end

  def contact
  end

  def new_course_modal
  end

  def python_ruby_modal
  end
end
