class QuestionsController < ApplicationController
  def index
  end

  def show
  end

  def new
    #pre: nothing
    #post: a new question object
      #question#new is rendered

    @question = Question.new

    #TODO we need a route for users to ask a question about a paticular exercise.


  end

  def create
    @question = Question.new(safe_assign)
    @question.user_id = current_user.id

    if @question.save
      flash[:success] = "Question saved!"
      redirect_to questions_path
    else
      flash[:error] = "Error creating your question."
      render 'new'
    end

  end

  def edit
    @question = Question.find(params[:id])
  end

  def update
    @question = Question.find(params[:id])
    @question.assign_attributes(safe_assign)

    if @question.save
      flash[:success] = "Question saved!"
      redirect_to questions_path
    else
      flash[:error] = "Error updating question."
      render 'new'      
    end
  end

  def delete
  end

  def destroy
  end

  private
  def safe_assign
    params.require(:question).permit(:title, :body, :tags)
  end

end
