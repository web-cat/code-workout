class ResponsesController < ApplicationController
  def index
  end

  def show
	@response = Response.find(params[:id])
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
