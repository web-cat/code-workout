class ResourceFilesController < ApplicationController
   before_action :set_resource_file, only: [:show]
 
  def new
  end

  # GET /resource_files/16325fe32
  def show
  end
  
  def index
    @resource_files = ResourceFile.all
  end

  def uploadFile
    puts "HINTER",params[:resource_file][:upload],"HINTER"
    post = ResourceFile.last.save_file(params[:resource_file][:upload])
    post.user_id=current_user.id  
    post.save!
    
  end
 
  # PATCH/PUT /update/1
  def update
    if uploadFile
      render action: 'show'
    else
      render action: 'edit'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource_file
      @resource_file = ResourceFile.find_by_token(params[:id])
    end
    
        # Only allow a trusted parameter "white list" through.
    
end