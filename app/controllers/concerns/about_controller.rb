class AboutController < ActionController::Base
layout 'application'  


 def index
    @choices = Choice.all
  end
end