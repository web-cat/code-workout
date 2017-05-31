class UserGroupsController < ApplicationController
  load_and_authorize_resource

  # -----------------------------------------
  # GET /user_groups/:user_group_id/members
  def members
    @user_group = UserGroup.find params[:user_group_id]
    @users = params[:notin] ? User.not_in_group(@user_group) : @user_group.users

    if params[:term]
      @users = @users.where('first_name regexp (?) or last_name regexp (?)
        or email regexp (?)', params[:term], params[:term], params[:term])
    end

    render json: @users.to_json and return
  end

  # -----------------------------------------------
  # POST /user_groups/:user_group_id/add_user/:user_id
  def add_user
    @user_group = UserGroup.find params[:user_group_id]
    @user = User.find params[:user_id]

    if !@user.is_a_member_of?(@user_group) &&
      @user_group.add_user_to_group(@user)

      render json: { id: @user.id, name: @user.display_name, url: user_path(@user.id) } and return
    else
      message = 'Unable to add that user to the group. They may already be a member.'
      render json: { error: message }.to_json and return
    end
  end

  # Takes the user_group member to a page to approve or deny the request
  # for access. If the user_group member is not signed in, makes them
  # sign in first. In the abilities file, this action is 'allowed to everyone'
  # since we take care of permissions here.
  # GET /user_groups/:user_group_id/review_access_request/:requester_id/:user_id
  def review_access_request
    @requester = User.find params[:requester_id]
    @user_group = UserGroup.find params[:user_group_id]
    @user = User.find params[:user_id]
    if !(current_user && current_user == @user)
      sign_out if current_user
      current_url = user_group_review_access_request_path(
        user_group_id: params[:user_group_id],
        user_id: params[:user_id],
        requester_id: params[:requester_id]
      )
      login_url = new_user_session_path(redirect_to: current_url)

      flash[:notice] = "Please sign in as #{@user.display_name} to review an access request."
      redirect_to login_url
    end
  end
end
