class ResourceFilesController < ApplicationController
  before_action :set_resource_file, only: [:show]


  #~ Action methods ...........................................................

  # -------------------------------------------------------------
  def new
    if cannot? :new, ResourceFile
      redirect_to root_path,
        notice: 'Unauthorized to create resource file' and return
    end
  end


  # -------------------------------------------------------------
  # GET /resource_files/16325fe32
  def show
    if cannot? :show, @resource_file
      redirect_to root_path,
        notice: 'Unauthorized to view resource file' and return
    end
  end


  # -------------------------------------------------------------
  def index
    if cannot? :index, ResourceFile
      redirect_to root_path,
        notice: 'Unauthorized to view all resource files' and return
    end
    @resource_files = ResourceFile.all
  end


  # -------------------------------------------------------------
  def uploadFile
    if cannot? :uploadFile, ResourceFile
      redirect_to root_path,
        notice: 'Unauthorized to upload resource file' and return
    end
    post = ResourceFile.last.save_file(params[:resource_file][:upload])
    post.user_id = current_user.id
    post.save!
  end


  # -------------------------------------------------------------
  # PATCH/PUT /update/1
  def update
    if cannot? :update, ResourceFile
      redirect_to root_path,
        notice: 'Unauthorized to upload resource file' and return
    end
    if uploadFile
      render action: 'show'
    else
      render action: 'edit'
    end
  end


  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_file
      @resource_file = ResourceFile.find_by_token(params[:id])
    end

    # Only allow a trusted parameter "white list" through.

end
