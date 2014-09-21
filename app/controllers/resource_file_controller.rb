class ResourceFileController < ApplicationController
  before_action :set_resource_file, only: [:show, :edit, :update, :destroy]

  # GET /resource_files/16325fe32
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_file
      @resource_file = ResourceFile.find_by_token(params[:id])
    end
end