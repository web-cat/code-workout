class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def facebook
    internal_auth('Facebook')
  end


  # -------------------------------------------------------------
  def google_oauth2
    internal_auth('Google')
  end


  # -------------------------------------------------------------
  def cas
    internal_auth('VT CAS')
  end


  #~ Private instance methods .................................................
  private

  # -------------------------------------------------------------
  def internal_auth(kind)
    @user = User.from_omniauth(request.env['omniauth.auth'], current_user)
    if @user.persisted?
      set_flash_message(:notice, :success, kind: kind) if
        is_navigational_format?
      sign_in_and_redirect @user
    else
      session['devise.omniauth_data'] = request.env['omniauth.auth']
      set_flash_message(:warning, :failure, kind: kind) if
        is_navigational_format?
      redirect_to new_user_registration_url
    end
  end

end
