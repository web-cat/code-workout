class UploadRosterController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :course_offering


  #~ Action methods ...........................................................

  # -------------------------------------------------------------
  # GET /course_offering/[id]/upload_roster.js
  def index
    @uploaded_roster = UploadedRoster.new

    #respond_to do |format|
    #  format.js
    #end
  end


  # -------------------------------------------------------------
  # POST /course_offering/[id]/upload_roster/upload.js
  def upload
    @uploaded_roster = UploadedRoster.new(params)

    if params[:commit]
      # Called by clicking the button.
      handle_submit
    else
      # Called by uploading a file.
      handle_new_csv
    end
  end


  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    def handle_new_csv
      respond_to do |format|
        format.js
      end
    end


    # -------------------------------------------------------------
    def handle_submit
      if @uploaded_roster.save
        respond_to do |format|
          format.js do
            flash[:notice] =
              "Created #{@uploaded_roster.users_created.count} new users " \
              "and enrolled #{@uploaded_roster.users_enrolled.count} users."
          end
        end
      else
        respond_to do |format|
          format.js do
            flash[:error] = 'You must select exactly one column for e-mail ' \
              'and either full name or first and last name.'
            render template: 'application/place_flash',
              locals: { where: '#flashbar-placeholder' }
          end
        end
      end
    end

end
