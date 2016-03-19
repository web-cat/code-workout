class ResponsesController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def create
    @response = Response.new(safe_assign)
    @response.user_id = current_user.id

    if @response.save
      flash[:success] = "Response saved!"
      redirect_to question_path(@response.question.id)
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
    params.require(:response).permit( :text, :question_id )
  end

end
