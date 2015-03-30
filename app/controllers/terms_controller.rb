class TermsController < InheritedResources::Base

  # All standard action methods are inherited!

  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    # Only allow a trusted parameter "white list" through.
    def term_params
      params.require(:term).permit(:season, :starts_on, :ends_on, :year)
    end

end
