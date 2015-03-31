class TermsController < InheritedResources::Base
  load_and_authorize_resource

  # All standard action methods are inherited!

  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    # Only allow a trusted parameter "white list" through.
    def term_params
      params.require(:term).permit(:season, :starts_on, :ends_on, :year)
    end


    # -------------------------------------------------------------
    # Defines resource human-readable name for use in flash messages.
    def interpolation_options
      { resource_name: @term.display_name }
    end

end
