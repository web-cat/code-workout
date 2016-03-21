class QuestionsController < ApplicationController
  def index
	@questions = Question.all
  end

  def show
	@question = Question.find(params[:id])
	@responses = Response.all.where(question_id: params[:id])
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def delete
  end

  def destroy
  end
end
