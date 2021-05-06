class TracesController < ApplicationController
  def index
    @trace = Trace.all
  end

  def show
    @trace = Trace.find(params[:id])
  end
end
