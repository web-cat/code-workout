require 'csv'

# =============================================================================
# Represents a roster uploaded as a CSV file.
#
class UploadedRoster

  COLUMN_IGNORE = 0
  COLUMN_FIRST_NAME = 1
  COLUMN_LAST_NAME = 2
  COLUMN_FULL_NAME = 3
  COLUMN_EMAIL = 4
  COLUMN_PASSWORD = 5
  NUMBER_OF_COLUMNS = 6

  COLUMNS = [
    ['(ignore)',         COLUMN_IGNORE],
    ['First Name',       COLUMN_FIRST_NAME],
    ['Last Name',        COLUMN_LAST_NAME],
    ['Last Name, First', COLUMN_FULL_NAME],
    ['E-mail',           COLUMN_EMAIL],
    ['Password',         COLUMN_PASSWORD]
  ]


  #~ Public methods ...........................................................

  # -------------------------------------------------------------
  # Params should include:
  #   course_offering_id: the ID of the course offering to enroll users in
  #   course_role_id: the ID of the course role to assign the enrolled users
  #   roster: the uploaded CSV file
  #   columns: a Hash with numbered entries that defines the column mapping
  #   has_headers: true to ignore the first row, false to include it
  #
  def initialize(params = {})
    @uploaded_file = params[:roster]
    @column_hash = params[:columns] || {}
    @has_headers = params[:has_headers]
    @course_role_id = params[:course_role_id]
    @course_offering = CourseOffering.find_by_id(params[:id])

    @users_created = []
    @users_enrolled = []

    @preview_rows = []
    @column_array = []

    process_csv if @uploaded_file
  end


  # -------------------------------------------------------------
  # Public: Gets any Users that were newly created when this roster was
  # uploaded.
  #
  # Returns an Array containing Users that were created.
  #
  def users_created
    @users_created
  end


  # -------------------------------------------------------------
  # Public: Gets any Users that were enrolled when this roster was uploaded;
  # that is, any users who were not already in the course offering.
  #
  # Returns an Array containing Users that were enrolled.
  #
  def users_enrolled
    @users_enrolled
  end


  # -------------------------------------------------------------
  def valid?
    @csv ? true : false
  end


  # -------------------------------------------------------------
  def preview_rows
    valid? ? @csv.first(5) : []
  end


  # -------------------------------------------------------------
  def column_count
    valid? ? @csv.first.count : 0
  end


  # -------------------------------------------------------------
  def column_mapping
    @column_hash
  end


  # -------------------------------------------------------------
  # Public: Creates the Users in the roster and adds them to the course
  # offering.
  #
  # Returns true if the roster was processed successfully, otherwise false.
  #
  def save
    column_counts = [0] * NUMBER_OF_COLUMNS
    columns = [nil] * NUMBER_OF_COLUMNS

    (0...@csv.first.count).each do |index|
      column = @column_hash[index.to_s].to_i
      columns[column] = index
      column_counts[column] += 1
    end

    # Check to make sure all of the required columns are provided.
    if column_counts[COLUMN_EMAIL] == 1 &&
      (column_counts[COLUMN_FULL_NAME] == 1 ||
        (column_counts[COLUMN_FIRST_NAME] == 1 &&
          column_counts[COLUMN_LAST_NAME] == 1))

      course_role = CourseRole.find(@course_role_id)

      start = @has_headers ? 1 : 0
      @csv[start..-1].each do |row|
        email = row[columns[COLUMN_EMAIL]]

        if columns[COLUMN_FULL_NAME]
          # If the full name column was provided, parse it to get the first
          # and last names separately (they must be comma-delimited).
          full_name = row[columns[COLUMN_FULL_NAME]]
        else
          # Otherwise, just pull the first and last names from their own
          # columns and merge them into a full name.
          full_name = [
            row[columns[COLUMN_FIRST_NAME]],
            row[columns[COLUMN_LAST_NAME]]
          ].reject { |name| name.blank? }.join(' ')
        end

        if columns[COLUMN_PASSWORD]
          password = row[columns[COLUMN_PASSWORD]]
        else
          # A User record cannot be saved without a password, so if none is
          # provided we create a random one.
          password = Devise.friendly_token.first(20)
        end

        if columns[COLUMN_FIRST_NAME] && columns[COLUMN_LAST_NAME]
          first_name = row[columns[COLUMN_FIRST_NAME]]
          last_name = row[columns[COLUMN_LAST_NAME]]
        elsif not(full_name.nil?)
          # needs a first and last name so extract it from full name
          first_name = full_name.split(" ").first
          last_name = full_name.split(" ").second
        else
          first_name = "No"
          last_name = "Name"
        end

        user = User.where(email: email).first

        if !user
          # The user doesn't exist yet, so create him/her and enroll in the
          # course.
          user = User.create(
            email: email,
            first_name: first_name,
            last_name: last_name,
            password: password)

          enrollment = CourseEnrollment.create(
            course_offering: @course_offering,
            user: user,
            course_role: course_role)

          users_created << user
          users_enrolled << user
        else
          # If the user already exists, only enroll him/her if not already
          # enrolled in the course.
          unless CourseEnrollment.where(
            course_offering_id: @course_offering.id,
            user_id: user.id).exists?

            enrollment = CourseEnrollment.create(
              course_offering: @course_offering,
              user: user,
              course_role: course_role)

            users_enrolled << user
          end
        end
      end

      true
    else
      false
    end
  end


  #~ Private methods ..........................................................

  private

  # -------------------------------------------------------------
  def process_csv
    roster_text = @uploaded_file.read
    @csv = CSV.parse(roster_text, headers: false)
    @preview_rows = @csv.first(5)

    unless @column_hash
      # Pre-populate with Virginia Tech defaults if it matches the Banner
      # format.
      #
      # TODO make this a little smarter, at least to detect e-mail addresses
      # automatically.
      if @csv.first.count == 11
        @column_hash = {}
        @column_hash[3] = COLUMN_LAST_NAME
        @column_hash[4] = COLUMN_FIRST_NAME
        @column_hash[8] = COLUMN_EMAIL
      end
    end

    (0...@csv.first.count).each do |index|
      if @column_hash
        @column_array << @column_hash[index.to_s].to_i
      else
        @column_array << 0
      end
    end
  end

end
