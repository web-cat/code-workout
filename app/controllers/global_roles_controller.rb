class GlobalRolesController < ApplicationController
  before_action :set_global_role, only: [:show, :edit, :update, :destroy]

  # GET /global_roles
  def index
    @global_roles = GlobalRole.all
  end

  # GET /global_roles/1
  def show
  end

  # GET /global_roles/new
  def new
    @global_role = GlobalRole.new
  end

  # GET /global_roles/1/edit
  def edit
  end

  # POST /global_roles
  def create
    @global_role = GlobalRole.new(global_role_params)

    if @global_role.save
      redirect_to @global_role, notice: 'Global role was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /global_roles/1
  def update
    if @global_role.update(global_role_params)
      redirect_to @global_role, notice: 'Global role was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /global_roles/1
  def destroy
    @global_role.destroy
    redirect_to global_roles_url, notice: 'Global role was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_global_role
      @global_role = GlobalRole.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def global_role_params
      params.require(:global_role).permit(:name, :can_manage_all_courses, :can_edit_system_configuration, :builtin)
    end
end
