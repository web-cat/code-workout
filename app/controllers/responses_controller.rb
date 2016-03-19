class ResponsesController < ApplicationController
  def index
  end

  def show
  end

  def new
    @q_id = 1
    @response = Response.new({
      :question_id => @q_id		
    })
  end

  def create
    @response = response.new(safe_assign)
    @response.user_id = current_user.id

    if @response.save
      flash[:success] = "Response saved!"
      redirect_to questions_path
    else
      flash[:error] = "Error creating your response."
      # render :template => "questions/show"
    end
  end

  def edit
  end

  def update
  end

  def delete
  end

  def destroy
  end

  private
  def safe_assign
    params.require(:response).permit(:text)
  end

end
