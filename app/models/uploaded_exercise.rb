require 'csv'

# =============================================================================
# Represents a set of exercises uploaded as a CSV file.
#
class UploadedExercise

  COLUMN_TYPE = 0
  COLUMN_ID = 1
  COLUMN_POINTS = 2
  COLUMN_PROMPT = 3
  COLUMN_ANSWER = 4
  COLUMN_CHOICE_A = 5
  COLUMN_CHOICE_B = 6
  COLUMN_CHOICE_C = 7
  COLUMN_CHOICE_D = 8
  COLUMN_CHOICE_E = 9
  COLUMN_CHOICE_F = 10
  COLUMN_CHOICE_G = 11
  COLUMN_CHOICE_H = 12
  COLUMN_CHOICE_I = 13
  COLUMN_CHOICE_J = 14
  COLUMN_EXPLANATION = 15
  NUMBER_OF_COLUMNS = 16

  COLUMNS = [
    ['Exercise Type', COLUMN_TYPE],
    ['ID',            COLUMN_ID],
    ['Points',        COLUMN_POINTS],
    ['Prompt',        COLUMN_PROMPT],
    ['Answer',        COLUMN_ANSWER],
    ['Choice A',      COLUMN_CHOICE_A],
    ['Choice B',      COLUMN_CHOICE_B],
    ['Choice C',      COLUMN_CHOICE_C],
    ['Choice D',      COLUMN_CHOICE_D],
    ['Choice E',      COLUMN_CHOICE_E],
    ['Choice F',      COLUMN_CHOICE_F],
    ['Choice G',      COLUMN_CHOICE_G],
    ['Choice H',      COLUMN_CHOICE_H],
    ['Choice I',      COLUMN_CHOICE_I],
    ['Choice J',      COLUMN_CHOICE_J],
    ['Explanation', COLUMN_EXPLANATION]
  ]


  #~ Public methods ...........................................................

  # -------------------------------------------------------------
  # Params should include:
  #   spreadsheet: the uploaded CSV file
  #   columns: a Hash with numbered entries that defines the column mapping
  #   has_headers: true to ignore the first row, false to include it
  #
  def initialize(params = {})
    @uploaded_file = params[:spreadsheet]
    @has_headers = params[:has_headers]

    @exercises_created = []

    @preview_rows = []

    process_csv if @uploaded_file
  end


  # -------------------------------------------------------------
  # Public: Gets any Exericses that were imported upon upload
  #
  # Returns an Array containing Exercises that were created.
  #
  def exercises_created
    @exercises_created
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
  # Public: Creates the exercises with corresponding choices
  #
  # Returns true if the spreadsheet was processed successfully, otherwise false.
  #
  def save
    # Process each row as an exercise
    @csv[0..-1].each_with_index do |row, i|
      # Make sure all columns are present
      if @csv.first.count != NUMBER_OF_COLUMNS
        false
      end

      exercise = Exercise.new

      type = row[COLUMN_TYPE]
      if type.eql?"MC"
        exercise.question_type = Exercise.type_mc
        #TODO determine if scrambled questions and/or if multiple selections are allowed
        exercise.mcq_allow_multiple = false
        exercise.mcq_is_scrambled = false
        ans = row[COLUMN_ANSWER].upcase.ord - 'A'.ord #A=0, B=1, ...
        (COLUMN_CHOICE_A..COLUMN_CHOICE_J).each do |index|
          choice = Choice.new
          choice.answer = row[index]
          choice_num = index - COLUMN_CHOICE_A
          choice.position = choice_num + 1
          if ans == choice_num
            choice.value = 100
          else
            choice.value = 0
          end
          #TODO tag exercises intelligently, not just hardcoded "imported"
          Tag.tag_this_with(exercise, "imported", Tag.misc)
          unless choice.answer.nil?
            exercise.choices << choice
            choice.save
          end
        end
      end

      #TODO get (exercise name, is_public, priority, experience, difficulty) not hardcoded
      exercise.count_attempts = 0
      exercise.count_correct = 0
      exercise.name = "Imported " + index
      exercise.is_public = true
      exercise.priority = 0
      exercise.experience = 100
      exercise.difficulty = 100
      exercise.discrimination = 0
      exercise.question = row[COLUMN_PROMPT]

      if exercise.save
        @exercises_created << exercise
        true
      else
        false
      end
    end
  end


  #~ Private methods ..........................................................

  private

  # -------------------------------------------------------------
  def process_csv
    spreadsheet_text = @uploaded_file.read
    @csv = CSV.parse(spreadsheet_text, headers: @has_headers)
    @preview_rows = @csv.first(5)
  end

  def letter_to_num( letter )
    letter.upcase.ord - 'A'.ord
  end
end