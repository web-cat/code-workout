class UsersController < InheritedResources::Base
  load_and_authorize_resource


  #~ Action methods ...........................................................

  # -------------------------------------------------------------
  # GET /users/1/performance
  def calc_performance
    #tries = @user.attempts
    #exs = Array.new
    #tries.each do |t|
    #  exs.push t.exercise_id
    #end

    tags = TagUserScore.where(user_id: params[:user_id]).
      order("updated_at DESC")
    @tag_scores = Array.new
    tags.each do |t|
      tag = t.tag
      if tag.total_experience > 0
        info = Hash.new
        info[:tag_name] = tag.tag_name
        info[:percent_experience] = t.experience * 100 / tag.total_experience
        info[:total_exercises] = tag.total_exercises
        info[:completed_exercises] = t.completed_exercises
        @tag_scores << info
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @tag_scores }
    end
  end

  def show
    @user = User.find params[:id]
    @workout_scores = @user.workout_scores.select{ |ws|
      if ws.workout_offering
        ws.workout_offering.can_be_seen_by?(@user)
      else
        true
      end
    }
  end

  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :time_zone_id, :avatar)
    end


    # -------------------------------------------------------------
    # Defines resource human-readable name for use in flash messages.
    def interpolation_options
      { resource_name: @user.display_name }
    end

end
