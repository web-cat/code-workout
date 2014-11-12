class ResourceFilesController < ApplicationController
   before_action :set_resource_file, only: [:show]

  # GET /resource_files/16325fe32
  def show
  end

  def uploadFile
    post = ResourceFile.write_file(params[:upload])
    render :text => "File uploaded."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_file
      @resource_file = ResourceFile.find_by_token(params[:id])
    end
end