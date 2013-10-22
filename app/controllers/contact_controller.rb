class ContactController < ActionController::Base
layout 'application'  


 def index
    @choices = Choice.all
  end
end