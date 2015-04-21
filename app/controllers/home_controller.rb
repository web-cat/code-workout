class HomeController < ApplicationController
  layout 'application', except: [:index]
  respond_to :html, except: [:new_course_modal]
  respond_to :js, only: [:new_course_modal]

  def index
  end

  def about
  end

  def license
  end

  def contact
  end

  def new_course_modal
  end

end
