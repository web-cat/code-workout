class StaticPagesController < ApplicationController

  layout 'two_columns'  

  def home
    @user=User.new
  end

  def help
  end

  def mockup1
    render :layout => 'sidebar_mockup'
  end

  def mockup2
  end

  def mockup3
  end
  
  def home2
        render :layout => 'application'
  end
  
  def excercises_in_workout
      render :layout => 'mockup'
  end
end
