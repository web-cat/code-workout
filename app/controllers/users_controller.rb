class UsersController < ApplicationController
  before_action :set_user,
    only: [:show, :edit, :update, :destroy, :calc_performance]
  authorize_resource except: [:show, :index]


  #~ Action methods ...........................................................

  # -------------------------------------------------------------
  # GET /users
  def index
    if cannot? :index, User
      redirect_to root_path, notice: 'Unauthorized to view users' and return
    end

    @users = User.all.page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @users }
    end
  end


  # -------------------------------------------------------------
  # GET /users/1
  def show
    if can? :show, @user
      puts "PASS"
    else
      redirect_to root_path, notice: 'Unauthorized to view user' and return
    end
  end


  # -------------------------------------------------------------
  # GET /users/new
  def new
    @user = User.new
  end


  # -------------------------------------------------------------
  # GET /users/1/edit
  def edit
    if cannot? :index, User
      redirect_to root_path, notice: 'Unauthorized to edit user' and return
    end
  end


  # -------------------------------------------------------------
  # GET /users/1/performance
  def calc_performance
    #tries = @user.attempts
    #exs = Array.new
    #tries.each do |t|
    #  exs.push t.exercise_id
    #end

    tags = TagUserScore.where(:user_id => params[:id]).order("updated_at DESC")
    @tag_scores = Array.new
    tags.each do |t|
      info = Hash.new
      tag = Tag.find(t.tag_id)
      info[:tag_name] = tag.tag_name
      tag.total_experience != 0 ?
        info[:percent_experience] = t.experience*100/tag.total_experience :
        info[:percent_experience] = 0
      info[:total_exercises] = tag.total_exercises
      info[:completed_exercises] = t.completed_exercises
      @tag_scores.push info
    end
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @tag_Scores }
    end
  end


  # -------------------------------------------------------------
  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render action: 'new'
    end
  end


  # -------------------------------------------------------------
  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end


  # -------------------------------------------------------------
  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end


  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end


    # -------------------------------------------------------------
    # Only allow a trusted parameter "white list" through.
    def user_params
#      if !can? :manage, User
#        params.delete(...)
#      end
      params.require(:user).permit(:first_name, :last_name, :email, :avatar)
    end
end
