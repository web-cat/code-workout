class ResourceFileController < ApplicationController
  before_action :set_resource_file, only: [:show, :uploadFile]

  # GET /resource_files/16325fe32
  def show
  end

  def uploadFile
    post = ResourceFile.save_file(params[:upload])
    render :text => "File uploaded."
    post.save!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_file
      @resource_file = ResourceFile.find_by_token(params[:id])
    end
end