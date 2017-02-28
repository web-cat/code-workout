class OrganizationsController < ApplicationController

  # -------------------------------------------------------------
  def index
    if params[:term_id]
      @term = Term.find(params[:term_id])
    else
      @term = Term.current_term
    end

    # equivalent to load_and_authorize_resource.
    # The authorize is handled with accessible_by, then the load is
    # performed with a custom query
    @organizations = Organization.accessible_by(current_ability).
      includes(courses: :course_offerings).
      joins(courses: :course_offerings).
      where('course_offerings.term_id' => @term).
      distinct
  end

  def search
    if params[:suggestion] && params[:term]
      @organizations = Organization.where('slug like ?', "#{params[:term]}%").order('slug asc')
    elsif params[:slug] && params[:term]
      @organizations = Organization.find_by(slug: params[:term]) # leaving the name pluralized for rendering
    elsif params[:term]
      @organizations = Organization.where('lower(name) like ? or lower(abbreviation) like ? or slug like ?',
        "%#{params[:term].downcase}%", "%#{params[:term].downcase}%", "%#{params[:term]}%")
    else
      @organizations = Organization.all
    end

    render json: @organizations.to_json and return
  end

  # -------------------------------------------------------------
  def show
    if params[:term_id]
      @term = Term.find(params[:term_id])
    else
      @term = Term.current_term
    end

    # equivalent to load_and_authorize_resource.
    # The authorize is handled with accessible_by, then the load is
    # performed with a custom query
    @organization = Organization.accessible_by(current_ability).
      includes(courses: :course_offerings).
      joins(courses: :course_offerings).
      where('course_offerings.term_id' => @term).
      find(params[:id])
  end

  def new_or_existing
    authorize! :new_or_existing, Organization, message: 'You must be signed in to start the course setup process.'
    render layout: 'one_column'
  end

  def create
    @organization = Organization.new(
      name: params[:name],
      abbreviation: params[:abbreviation],
      slug: params[:abbreviation].downcase
    )

    if @organization.save
      success = true
    else
      success = false
    end

    result = { success: success, id: @organization.slug }

    render json: result and return
  end

  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    # Only allow a trusted parameter "white list" through.
    def organization_params
      params.require(:organization).permit(:name, :abbreviation, :term_id)
    end


    # -------------------------------------------------------------
    # Defines resource human-readable name for use in flash messages.
    def interpolation_options
      { resource_name: @organization.name }
    end


end
