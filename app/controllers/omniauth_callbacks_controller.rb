class OmniauthCallbacksController < ApplicationController
  
  def facebook     
     @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)      
     if @user.persisted?       
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
  
   def google_oauth2
     user = User.from_omniauth(request.env["omniauth.auth"])
     if user.persisted?
       flash.notice = "Signed in Through Google!"
       sign_in_and_redirect user
     else
       session["devise.user_attributes"] = user.attributes
       flash.notice = "You are almost Done! Please provide a password to finish setting up your account"
       redirect_to new_user_registration_url
     end
   end
end
