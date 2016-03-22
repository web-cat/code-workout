class QuestionsController < ApplicationController
  def index
	@questions = Question.all
  end

  def show
    @question = Question.find(params[:id])
    @responses = Response.all.where(question_id: params[:id])
    @response = Response.new
  end

  def new
    #pre:
      #exercise_id (optional): the exercise this question should be associated
      #with
    #post: a new question object is instantiated but not saved
      #question#new is rendered

    @question = Question.new({
      :exercise_id => params[:exercise_id]
      })

  end

  def create
    #pre:
      #params: the parameters to be used to create this question
    #post: 
      #a new question object is saved -> redirect to index
      #OR new question is not saved -> render new
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
    #pre:
      #id: the id of the question to edit
    #post:
      #edit view is rendered
    @question = Question.find(params[:id])
  end

  def update
    #pre:
      #params: question attributes to be assigned
    #post
      #the question object is saved -> redirect to index
      #OR new question is not saved -> render edit
    @question = Question.find(params[:id])
    @question.assign_attributes(safe_assign)

    if @question.save
      flash[:success] = "Question saved!"
      redirect_to questions_path
    else
      flash[:error] = "Error updating question."
      render 'edit'      
    end
  end

  def delete
  end

  def destroy
  end

  private
  def safe_assign
    params.require(:question).permit(:title, :body, :tags, :exercise_id)
  end

end
