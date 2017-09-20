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
    @access_request = @user_group.group_access_requests.find_by(user: @requester)
    if @access_request && request.get?
      get_review_access_request
    elsif @access_request && request.post?
      post_review_request_access and return
    else
      flash[:error] = 'Unidentified access request. No action required.'
      redirect_to root_path and return
    end
  end

  private
  def get_review_access_request
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

    if !@access_request.pending
      decision = @access_request.decision ? 'accepted' : 'rejected'
      flash[:notice] = "This request was <strong>#{decision}</strong>. No further action required.".html_safe
    end
  end

  def post_review_request_access
    if !(@user.is_a_member_of?(@user_group) || @user.global_role.is_admin?)
      flash[:error] = "#{@user.display_name} is not authorized to add members to #{@user_group.name}."
      redirect_to root_path and return
    end
    if params[:decision]
      @user_group.add_user_to_group(@requester)
      @access_request.update(pending: false, decision: true)
    else
      @access_request.update(pending: false, decision: false)
    end
    decision = params[:decision] ? 'accepted' : 'rejected'
    flash[:notice] = "#{@requester.display_name}'s request was <strong>#{decision}</strong>.".html_safe
    redirect_to root_path
  end
end
