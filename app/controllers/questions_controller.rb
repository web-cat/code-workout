class QuestionsController < ApplicationController
  def index
  end

  def show
    @question = Question.find(params[:id])
    @response = Response.new
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
