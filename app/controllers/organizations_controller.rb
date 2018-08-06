class OrganizationsController < ApplicationController
include AbbrHelper
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
    
    if params[:enrolled_only].to_b
      @organizations = Organization.accessible_by(current_ability).
        includes(courses: { course_offerings: :course_enrollments } ).
        joins(courses: { course_offerings: :course_enrollments } ).
        where('course_offerings.term_id' => @term, 'course_enrollments.user_id' => current_user.id).
        distinct
    else
      @organizations = Organization.accessible_by(current_ability).
        includes(courses: :course_offerings).
        joins(courses: :course_offerings).
        where('course_offerings.term_id' => @term).
        distinct
    end
  end

  def search
    if params[:slug] && params[:term]
      @organizations = Organization.find_by(slug: params[:term]) # leaving the name pluralized for rendering
    elsif params[:term]
      @organizations = Organization.where('lower(name) like ? or lower(abbreviation) like ? or slug like ?',
        "%#{params[:term].downcase}%", "%#{params[:term].downcase}%", "%#{params[:term]}%")
    else
      @organizations = Organization.all
    end

    render json: @organizations.to_json and return
  end

  def abbr_suggestion
    unless params[:name]
      render json: nil and return
    end

    name = to_title_case(params[:name])
    strategies = ['caps', 'states', 'lowers']
    success = false
    abbr = nil

    for strategy in strategies
      case strategy
      when 'caps'
        abbr = caps_strategy(name)
        unless (abbr && Organization.exists?(slug: abbr.downcase))
          success = true
          break
        end
      when 'states'
        abbr = states_strategy(name)
        unless (abbr && Organization.exists?(slug: abbr.downcase))
          success = true
          break
        end
      when 'lowers'
        abbr = lowers_strategy(name)
        unless (abbr && Organization.exists?(slug: abbr.downcase))
          success = true
          break
        end
      end
    end

    if abbr && success
      render json: { abbr: abbr } and return
    else
      render json: { abbr: nil, msg: 'Could not auto-generate a unique abbreviation. Please enter a suitable one yourself.'} and return
    end
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
      name: to_title_case(params[:name]),
      abbreviation: params[:abbreviation],
      slug: params[:abbreviation].downcase,
      is_hidden: params[:is_hidden]
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
