class ExercisesController < ApplicationController
  before_action :set_exercise, only: [:show, :edit, :update, :destroy]


  #~ Action methods ...........................................................

  # -------------------------------------------------------------
  # GET /exercises
  def index
    if cannot? :index, Exercise
      redirect_to root_path,
        notice: 'Unauthorized to view all exercises' and return
    end
    @exercises = Exercise.all
  end


  # -------------------------------------------------------------
  # GET /exercises/download.csv
  def download
    if cannot? :index, Exercise
      redirect_to root_path,
        notice: 'Unauthorized to view all exercises' and return
    end
    @exercises = Exercise.accessible_by(current_ability)

    respond_to do |format|
      format.csv
      format.json do
        render text:
          ExerciseRepresenter.for_collection.new(@exercises).to_hash.to_json
      end
      format.yml do
        render text:
          ExerciseRepresenter.for_collection.new(@exercises).to_hash.to_yaml
      end
    end
  end


  # -------------------------------------------------------------
  def search
    @terms = escape_javascript(params[:search])
    @terms = @terms.split(@terms.include?(',') ? /\s*,\s*/ : nil)
    @wos = Workout.search @terms
    @exs = Exercise.search @terms
    if @wos.length + @exs.length > 0
      @msg = ''
    else
      @msg = 'No ' + searched + ' exercises found. Try these instead...'
      @wos = Workout.order('RANDOM()').limit(4)
      @exs = Exercise.order('RANDOM()').limit(16)
    end
  end


  # -------------------------------------------------------------
  # GET /exercises/1
  def show
  end


  # -------------------------------------------------------------
  # GET /exercises/new
  def new
    if !user_signed_in? || (cannot? :new, Exercise)
      redirect_to root_path,
        notice: 'Unauthorized to create new exercise' and return
    end
    @exercise = Exercise.new
    @coding_exercise = CodingQuestion.new
    @languages = Tag.where(tagtype: Tag.language).pluck(:tag_name)
    @areas = Tag.where(tagtype: Tag.area).pluck(:tag_name)
  end


  # -------------------------------------------------------------
  # GET /exercises/1/edit
  def edit
    if !user_signed_in? || (cannot? :edit, @exercise)
      redirect_to root_path,
        notice: 'Unauthorized to edit exercise' and return
    end
  end


  # -------------------------------------------------------------
  # POST /exercises
  def create
    if !user_signed_in? || (cannot? :exercise, Exercise)
      redirect_to root_path,
        notice: 'Unauthorized to create exercise' and return
    end
    basex=BaseExercise.new
    ex=Exercise.new
    msg = params[:exercise] || params[:coding_question]
    basex.user_id = current_user.id
    basex.question_type = msg[:question_type] || 1
    basex.versions = 1
    ex.name = msg[:name].chomp.strip
    # ex.question = ERB::Util.html_escape(msg[:question])
    # ex.feedback = ERB::Util.html_escape(msg[:feedback])
    ex.question = msg[:question]
    ex.feedback = msg[:feedback]
    ex.creator_id = current_user.id
    ex.is_public = true
    if msg[:is_public] == 0
      ex.is_public = false
    end

    if msg[:mcq_allow_multiple].nil?
      ex.mcq_allow_multiple = false
    else
      ex.mcq_allow_multiple = msg[:mcq_allow_multiple]
    end

    if msg[:mcq_is_scrambled].nil?
      ex.mcq_is_scrambled = false
    else
      ex.mcq_is_scrambled = msg[:mcq_is_scrambled]
    end
    ex.priority = 0
    # TODO: Get the count of attempts from the session
    ex.count_attempts = 0
    ex.count_correct = 0
    if msg[:language_id]
      ex.language_id = msg[:language_id].to_i
    end

    if msg[:experience]
      ex.experience = msg[:experience]
    else
      ex.experience = 10
    end

    # default IRT statistics
    ex.difficulty = 0
    ex.discrimination = 0
    ex.version = 1

    # Populate coding question's test case
    if msg[:coding_questions]
      codingquestion = CodingQuestion.new
      codingquestion.class_name =
        msg[:coding_questions][:class_name].chomp.strip
      codingquestion.method_name =
        msg[:coding_questions][:method_name].chomp.strip
      codingquestion.wrapper_code =
        msg[:coding_questions][:wrapper_code].chomp.strip
      codingquestion.test_script =
        msg[:coding_questions][:test_script].chomp.strip
      ex.coding_question = codingquestion
      extests = msg[:coding_questions][:test_script].strip.chomp.split("\n")
      extests.each do |tc|
        test_case = TestCase.new
        # FIXME:
        test_case.test_script = 'NONE for now'
        case_splits = tc.split(',')
        test_case.input = case_splits[0].strip.gsub(';', ',')
        test_case.expected_output = case_splits[1].strip
        test_case.weight = 1.0
        # FIXME:
        test_case.description = case_splits[2] unless case_splits[2].nil?
        test_case.negative_feedback = case_splits[3]
        ex.coding_question.test_cases << test_case
      end
    end

    basex.exercises << ex
    ex.save!
    basex.current_version = ex
    basex.save
    if msg[:coding_questions]
      msg[:tag_ids].delete_if(&:empty?)
      language = msg[:tag_ids][0]
      Dir.chdir('usr/resources') do
        test_end_code = generate_tests(ex.id, language,
          msg[:coding_questions][:class_name].chomp.strip,
          msg[:coding_questions][:method_name].chomp.strip)
        puts 'LANGUAGE', 'LANGUAGE', language, 'LANGUAGE', 'LANGUAGE'
        base_test_file = File.open(
          "#{language}BaseTestFile.#{Exercise.extension_of(language)}",
          'rb').read
        test_base = base_test_file.gsub('baseclassclass',
          msg[:coding_questions][:class_name].chomp.strip)

        if language == 'Java'
          first_input = ex.coding_question.test_cases[0].input
          first_expected_output =
            ex.coding_question.test_cases[0].expected_output
          if first_input == 'true' || first_input == 'false'
            puts 'BOOLEAN TYPE', 'BOOLEAN TYPE'
            input_type = 'boolean'
          elsif first_input.include?('"')
            puts 'STRING TYPE', 'STRING TYPE'
            input_type = 'String'
          elsif first_input.include?("'")
             puts 'CHAR TYPE', 'CHAR TYPE'
             input_type = 'char'
          elsif first_input.to_i.to_s == first_input
             puts 'INT TYPE', 'INT TYPE'
             input_type = 'int'
          elsif first_input.to_f.to_s == first_input
             puts 'FLOAT TYPE', 'FLOAT TYPE'
             input_type = 'float'
          else
             puts 'TYPE ERROR', 'TYPE ERROR'
             input_type = 'ERR'
          end
          if first_expected_output == 'true' ||
            first_expected_output == 'false'
            puts 'BOOLEAN TYPE', 'BOOLEAN TYPE'
            output_type = 'boolean'
          elsif first_expected_output.include?('"')
            puts 'STRING TYPE', 'STRING TYPE'
            output_type = 'String'
          elsif first_expected_output.include?("'")
            puts 'CHAR TYPE', 'CHAR TYPE'
            output_type = 'char'
          elsif first_expected_output.to_i.to_s == first_expected_output
            puts 'INT TYPE', 'INT TYPE'
            output_type = 'int'
          elsif first_expected_output.to_f.to_s == first_expected_output
            puts 'FLOAT TYPE', 'FLOAT TYPE'
            output_type = 'float'
          else
            puts 'TYPE ERROR', 'TYPE ERROR'
            output_type = 'ERR'
          end
          if output_type != 'ERR'
            test_base = test_base.gsub('methodnameemandohtem',
              msg[:coding_questions][:method_name].chomp.strip)
            test_base = test_base.gsub('input_type',input_type)
            test_base = test_base.gsub('output_type',output_type)

            base_runner_file = File.open("JavaBaseTestRunner.java","rb").read
            base_runner_code = base_runner_file.gsub('baseclassclass',
              msg[:coding_questions][:class_name].chomp.strip)
            File.open(msg[:coding_questions][:class_name].chomp.strip +
              'TestRunner.java', "wb") { |f| f.write( base_runner_code ) }
          end # !ERR IF
        end # JAVA IF
        testing_code = test_base.gsub('TTTTT', test_end_code)
        File.open(msg[:coding_questions][:class_name].chomp.strip + 'Test.' +
          Exercise.extension_of(language), 'wb') { |f| f.write(testing_code) }
      end
    end

    i = 0
    right = 0.0
    total = 0.0

    # typed in tags
    if msg[:tags_attributes]
      msg[:tags_attributes].each do |t|
        Tag.tag_this_with(ex, t.second["tag_name"].to_s, Tag.skill)
      end
    end

    # selected tags
    msg[:tag_ids].delete_if(&:empty?)
    puts 'TAG IDS', msg[:tag_ids], 'TAG IDS'
    msg[:tag_ids].each do |tag_name|
      Tag.tag_this_with(ex, tag_name.to_s, Tag.misc)
    end
    if msg[:choices_attributes]
      msg[:choices_attributes].each do |c|
        if c.second["value"] == "1"
          right += 1
        end
        total += 1
      end
      msg[:choices_attributes].each do |c|
        tmp = Choice.create
        tmp.answer = ERB::Util.html_escape(c.second[:answer])
        if( c.second["value"] == "1" )
          tmp.value = 1/right
        else
          tmp.value = 0
        end

        tmp.feedback = ERB::Util.html_escape(c.second[:feedback])
        tmp.order = i
        ex.choices << tmp
        #tmp.exercise << @exercise
        tmp.save!

        i=i+1
      end
    end
    if ex.save!
      redirect_to ex, notice: 'Exercise was successfully created.'
    else
      #render action: 'new'
      redirect_to ex, notice:
        "Exercise was NOT created for #{msg} #{@exercise.errors.messages}"
    end
  end


  # -------------------------------------------------------------
  def random_exercise
    exercise_dump = []
    if params[:language]
      Exercise.all.each do |baseexercise|
        candidate_exercise = baseexercise.current_version
        if candidate_exercise &&
          baseexercise.is_public &&
          baseexercise.language == params[:language]
          exercise_dump << candidate_exercise
        elsif !candidate_exercise
          puts "ERROR: base exercise #{baseexercise.id} with current " +
            "version #{baseexercise.current_version_id} does not refer to " +
            'an existing exercise.'
        end # INNER IF
      end   # DO WHILE

    elsif params[:question_type]
      Exercise.where(question_type: params[:question_type].to_i).
        find_each do |baseexercise|
        candidate_exercise = baseexercise.current_version
        if candidate_exercise && baseexercise.is_public
          exercise_dump << candidate_exercise
        elsif !candidate_exercise
          puts "ERROR: base exercise #{baseexercise.id} with current " +
            "version #{baseexercise.current_version_id} does not refer to " +
            'an existing exercise.'
        end # INNER IF
      end   # DO WHILE
    else
      Exercise.all.each do |baseexercise|
        candidate_exercise = baseexercise.current_version
        if candidate_exercise && baseexercise.is_public
          exercise_dump << candidate_exercise
        elsif !candidate_exercise
          puts "ERROR: base exercise #{baseexercise.id} with current " +
            "version #{baseexercise.current_version_id} does not refer to " +
            'an existing exercise.'
        end # INNER IF
      end   # DO WHILE
    end #OUTER IF
    puts "VICTARION",exercise_dump.sample,"VICTARION"
    redirect_to exercise_practice_path(exercise_dump.sample) and return
  end


  # -------------------------------------------------------------
  # POST exercises/create_mcqs
  def create_mcqs
    if !user_signed_in?
      redirect_to root_path, notice: 'Need to sign in first' and return
    end
    basex = BaseExercise.new
    basex.user = current_user
    basex.question_type = msg[:question_type] || 1
    basex.versions = 1
    csvfile = params[:form]
    puts csvfile.fetch(:xmlfile).path
    CSV.foreach(csvfile.fetch(:xmlfile).path) do |question|
      if $INPUT_LINE_NUMBER > 1
        name_ex = question[1]
        # priority_ex=question[2]
        question_ex = question[3][3..-5]

        if !question[15].nil? && question[15].include?('p')
          gradertext_ex = question[15][3..-5]
        else
          gradertext_ex = ''
        end

        if !question[5].nil? &&
          !question[6].nil? &&
          !question[5][3..-5].nil? &&
          !question[6][3..-5].nil?

          ex = Exercise.new
          ex.name = name_ex
          ex.question = question_ex
          ex.feedback = gradertext_ex
          ex.is_public = true
          ex.creator_id = current_user.id
          # if msg[:is_public] == 0
            # ex.is_public = false
          # end

          ex.mcq_allow_multiple = true

          # if msg[:mcq_allow_multiple].nil?
            # ex.mcq_allow_multiple = false
          # end

          ex.mcq_is_scrambled = true
          # if msg[:mcq_is_scrambled].nil?
            # ex.mcq_is_scrambled = false
          # end
          ex.priority = 1
          # TODO: Get the count of attempts from the session
          ex.count_attempts = 5
          ex.count_correct = 1
          ex.user = current_user
          ex.experience = 10

          # default IRT statistics
          ex.difficulty = 0
          ex.discrimination = 0

          ex.version = 1
          basex.exercises << ex
          ex.save!
          basex.current_version = ex
          basex.save

          #   i = 0
          #  right = 0.0
          # total = 0.0
          alphanum = {
            'A' => 1, 'B' => 2, 'C' => 3, 'D' => 4, 'E' => 5,
            'F' => 6, 'G' => 7, 'H' => 8, 'I' => 9, 'J' => 10 }
          choices = []
          choice1 = question[5][3..-5]
          choices << choice1
          choice2 = question[6][3..-5]
          choices << choice2
          if !question[7].nil? && question[7].include?('p')
            choice3 = question[7][3..-5]
            choices << choice3
          end
          if !question[8].nil? && question[8].include?('p')
            choice4 = question[8][3..-5]
            choices << choice4
          end
          if !question[9].nil? && question[9].include?('p')
            choice5 = question[9][3..-5]
            choices << choice5
          end
          if !question[10].nil? && question[10].include?('p')
            choice6 = question[10][3..-5]
            choices << choice6
          end
          if !question[11].nil? && question[11].include?('p')
            choice7 = question[11][3..-5]
            choices << choice7
          end
          if !question[12].nil? && question[12].include?('p')
            choice8 = question[12][3..-5]
            choices << choice8
          end
          if !question[13].nil? && question[13].include?('p')
            choice9 = question[13][3..-5]
            choices << choice9
          end
          if !question[14].nil? && question[14].include?('p')
            choice10 = question[14][3..-5]
            choices << choice10
          end

          if question[5] && question[6] &&
            question[5][3..-5] && question[6][3..-5]
            ex = Exercise.new
            ex.name = name_ex
            ex.question = question_ex
            ex.feedback = gradertext_ex
            ex.is_public = true

            # if msg[:is_public] == 0
            #   ex.is_public = false
            # end

            ex.mcq_allow_multiple = true

            # if msg[:mcq_allow_multiple].nil?
            #   ex.mcq_allow_multiple = false
            # end

            ex.mcq_is_scrambled = true
            # if msg[:mcq_is_scrambled].nil?
            #   ex.mcq_is_scrambled = false
            # end
            ex.priority = 1
            # TODO: Get the count of attempts from the session
            ex.count_attempts = 5
            ex.count_correct = 1

            ex.user = current_user
            ex.experience = 10

            # default IRT statistics
            ex.difficulty = 0
            ex.discrimination = 0
            ex.version = 1
            basex.exercises << ex
            ex.save!
            basex.current_version = ex
            basex.save

            #   i = 0
            #  right = 0.0
            # total = 0.0
            alphanum = {
              'A' => 1, 'B' => 2, 'C' => 3, 'D' => 4, 'E' => 5,
              'F' => 6, 'G' => 7, 'H' => 8, 'I' => 9, 'J' => 10 }
            choices = []
            choice1 = question[5][3..-5]
            choices << choice1
            choice2 = question[6][3..-5]
            choices << choice2
            if question[7] && question[7].include?('p')
              choice3 = question[7][3..-5]
              choices << choice3
            end
            if question[8] && question[8].include?('p')
              choice4 = question[8][3..-5]
              choices << choice4
            end
            if question[9] && question[9].include?('p')
              choice5 = question[9][3..-5]
              choices << choice5
            end
            if question[10] && question[10].include?('p')
              choice6 = question[10][3..-5]
              choices << choice6
            end
            if question[11] && question[11].include?('p')
              choice7 = question[11][3..-5]
              choices << choice7
            end
            if question[12] && question[12].include?('p')
              choice8 = question[12][3..-5]
              choices << choice8
            end
            if question[13] && question[13].include?('p')
              choice9 = question[13][3..-5]
              choices << choice9
            end
            if question[14] && question[14].include?('p')
              choice10 = question[14][3..-5]
              choices << choice10
            end
            cnt = 0
            choices.each do |choiceitem|
              ch = Choice.create
              ch.answer = choiceitem
              cnt += 1
              if alphanum[question[5]] == cnt
                ch.value = 1
              else
                ch.value = -1
              end

              ch.feedback = gradertext_ex
              ch.order = cnt
              ex.choices << ch
              # ch.exercise << @exercise
              ch.save!
            end

          else
            puts 'INVALID Question'
            puts 'INVALID choice', choice1
            puts 'INVALID choice', choice2
          end
        end # IF Valid fields
      end # IF 1
      redirect_to exercises_url, notice: 'Uploaded!'
    end # CSV do
  end# def


  # -------------------------------------------------------------
  # GET exercises/upload_mcqs
  def upload_mcqs
    if !user_signed_in? || !current_user.global_role.is_admin?
        redirect_to root_path,
          notice: 'You do not have permission to access this page.' and return
    end
  end


  # -------------------------------------------------------------
  # GET exercises/upload_exercises
  def upload
    if !user_signed_in? || !current_user.global_role.is_admin?
        redirect_to root_path,
          notice: 'You do not have permission to access this page.' and return
    end
  end

  def upload_yaml

  end

  def yaml_create
    @yaml_exers = YAML.load_file(params[:form].fetch(:yamlfile).path)
    @yaml_exers.each do |exercise|
      @ex = Exercise.new
      @ex.name = exercise['name']
      @ex.external_id = exercise['external_id']
      @ex.is_public = exercise['is_public']
      @ex.experience = exercise['experience']
      exercise['language_list'].split(",").each do |lang|
        print "\nLanguage: ", lang
      end
      exercise['style_list'].split(",").each do |style|
        print "\nStyle: ", style
      end
      exercise['tag_list'].split(",").each do |tag|
        print "\nTag: ", tag
      end
      version = exercise['current_version']
      @ex.versions = version['version']
      @ex.save!


      @version = ExerciseVersion.new(exercise: @ex,creator_id:
                 User.find_by(email: version['creator']).andand.id,
                 exercise: @ex,
                 position:1)
      @version.save!
      version['prompts'].each do |prompt|
        # FIXME: Need to incorporate mcqs too.
        prompt = prompt['coding_prompt']
        @prompt = CodingPrompt.new(exercise_version: @version)
        @prompt.question = prompt['question']
        @prompt.position = prompt['position']
        @prompt.feedback = prompt['feedback']
        @prompt.class_name = prompt['class_name']
        @prompt.method_name = prompt['method_name']
        @prompt.starter_code = prompt['starter_code']
        @prompt.wrapper_code = prompt['wrapper_code']
        @prompt.test_script = prompt['tests']
        @prompt.actable_id = rand(100)
        @prompt.save!

        prompt['tests'].split(/\r?\n/).each do |test|
          t = test.split(";")
          tc = TestCase.new(test_script: "None", weight: 1.0, coding_prompt: @prompt)
          tc.description = t[2]
          tc.negative_feedback = t[3]
          tc.input = t[0]
          tc.expected_output = t[1]
          tc.save!
        end
      end

    end
    redirect_to exercises_path
  end

  # -------------------------------------------------------------
  # POST /exercises/upload_create
  def upload_create
    if !user_signed_in? || !current_user.global_role.is_admin?
      redirect_to root_path,
          notice: 'You do not have permission to access this page.' and return
    end
    puts 'uploaded file = ', params[:form].fetch(:file).path
    puts 'uploaded file = ', params[:form][:file].path

    hash = YAML.load(File.read(params[:form][:file].path))
    exercises = ExerciseRepresenter.for_collection.new([]).from_hash(hash)
    exercises.each do |e|
      if !e.save
        puts 'cannot save exercise, name = ' + e.name.to_s +
          ', external_id = ' + e.external_id.to_s + ': ' +
          e.errors.full_messages.to_s
      end
    end
    puts 'exercises = ',
      ExerciseRepresenter.for_collection.new(exercises).to_hash.to_yaml

    # basex = BaseExercise.new
    # basex.user_id = current_user.id
    # basex.question_type = msg[:question_type] || 1
    # basex.versions = 1
    # questionfile = params[:form]
    # doc = Nokogiri::XML(File.open(questionfile.fetch(:file).path))
    # questions = doc.xpath('/quiz/question')
    # questions.each do |question|
      # ex = Exercise.new
      # name_ex = question.xpath('./name/text')[0].content
      # question_ex = question.xpath('./questiontext/text')[0].content
      # if !question.xpath('.//generalfeedback/text').empty?
        # feedback_ex = question.xpath('.//generalfeedback/text')[0].content
      # else
        # feedback_ex = ''
      # end
#
      # if !question.xpath('.//defaultgrade').empty?
        # priority_ex = question.xpath('.//defaultgrade')[0].content
      # else
        # priority_ex = 1.to_s
      # end
#
      # if !question.xpath('.//penalty').empty?
        # discrimination_ex = question.xpath('.//penalty')[0].content
      # else
        # discrimination_ex = 0.to_s
      # end
#
      # if !question.xpath('.//graderinfo').empty?
        # gradertext_ex = question.xpath('.//graderinfo/text')[0].content
      # else
        # gradertext_ex = ''
      # end
      # # TODO: Sanitize the uploads
      # ex.name = name_ex
      # ex.question = question_ex
      # ex.feedback = feedback_ex
      # ex.is_public = true
      # ex.mcq_allow_multiple = false
      # ex.mcq_is_scrambled = false
      # ex.priority = priority_ex
      # # TODO: Get the count of attempts from the session
      # ex.count_attempts = 1
      # ex.count_correct = 1
      # ex.user_id = current_user.id
      # ex.experience = 20
#
      # # default IRT statistics
      # ex.difficulty = 5
      # ex.discrimination = discrimination_ex
      # ex.version = 1
      # basex.exercises << ex
      # ex.save!
      # basex.current_version = ex
      # basex.save
    # end
    redirect_to exercises_url, notice: 'Exercise upload complete.'
  end


  # -------------------------------------------------------------
  # GET/POST /practice/1
  def practice
    # Tighter practice requirements for the moment, should go away as a part of the eventual-engagement model
    if !user_signed_in?
      redirect_to exercise_path(params[:id]),
        notice: 'Need to sign in first' and return
    end
    if( params[:id] )
      @found = Exercise.where(id: params[:id])
      if( @found.empty? )
        redirect_to exercises_url, notice: "Exercise E#{params[:id]} not found"
      elsif user_signed_in?
        @exercise = @found.first
        # Tighter restrictions for the moment, should go away
        if !current_user.global_role.can_edit_system_configuration?
          redirect_to root_path,
            notice: 'Exercise practice is temporarily disabled.' and return
        end
        if @exercise.is_mcq?
          @answers = @exercise.current_version.serve_choice_array
          @answers.each do |a|
            a[:answer] = markdown(a[:answer])
          end
        end
        @responses = ['There are no responses yet!']
        @explain = ['There are no explanations yet!']
        if session[:leaf_exercises]
          session[:leaf_exercises] << @exercise.id
        else
          session[:leaf_exercises] = [@exercise.id]
        end
        # EOL stands for end of line
        # @wexs is the variable to hold the list of exercises of this workout
        # yet to be attempted by the user apart from the current exercise
        if params[:wexes] != 'EOL'
          @wexs = params[:wexes] || session[:remaining_wexes]
        else
          @wexs = nil
        end
      else
        redirect_to exercise_path(found.first),
          notice: 'Need to login to practice' and return
      end
    else
      redirect_to exercises_url, notice: 'Choose an exercise to practice!'
    end
   # if params[:feedback_return]
   #   render layout: 'three_columns'
   # else
      render layout: 'two_columns'
   # end
   # respond_to do |format|
   #   format.html
   #   format.js
   # end

  end


  # -------------------------------------------------------------
  def create_choice
    @ans = Choice.create
    @pick.push()
  end


  # -------------------------------------------------------------
  #GET /evaluate/1
  def evaluate
    if !user_signed_in?
      redirect_to root_path, notice: 'Need to sign in first' and return
    end
    if params[:id]
      @exercise = Exercise.find(params[:id])
      if !@exercise
        redirect_to exercises_url, notice: "Exercise E#{params[:id]} not found"
      else
        attempt = Attempt.new(
          user: current_user,
          exercise_version: @exercise.current_version,
          submit_time: Time.now,
          submit_num: 1
          )
        attempt.save
        @att_id = attempt.id
        @user_id = current_user.id
        if @exercise.is_mcq?
          response_ids = params[:exercise][:exercise][:choice_ids]
          p params
          @responses = Array.new
          if @exercise.current_version.prompts.first.specific.allow_multiple
            response_ids.each do |r|
              @responses.push(Choice.where(id: r).first)
            end
          else
            @responses.push(Choice.where(id: response_ids).first)
          end
          @responses = @responses.compact
          @responses.each do |answer|
            answer[:answer] = markdown(answer[:answer])
          end
          @score = @exercise.score(@responses)
          if session[:current_workout]
            @score = @score * ExerciseWorkout.findExercisePoints(
              @exercise.id, session[:current_workout])
          end
          @explain = @exercise.collate_feedback(@responses)
          @exercise_feedback = 'You have attempted exercise ' +
            "#{@exercise.id}:#{@exercise.name}" +
            ' and its feedback for you: ' +
            @explain.to_sentence
          if session[:current_workout]
            record_workout_score(@score, @exercise.id,
              session[:current_workout])
            session[:workout_feedback][@exercise.id] = @exercise_feedback
          end
          # TODO: calculate experience based on correctness and num submissions
          count_submission()
          @xp = @exercise.experience_on(@responses, session[:submit_num])
          record_attempt(@score, @xp)
        elsif @exercise.is_coding?

#          CodeWorker.new.async.perform(
#            @exercise.current_version.prompts.first.specific.class_name,
#            @exercise.id,
#            @user_id,
#            params[:exercise][:answer_code],
#            session[:current_workout],
#            @att_id)

            # FIXME: Need to make it work for multiple prompts
            prompt_question =  CodingPrompt.find(@exercise.current_version.prompts.first.actable_id)
            prompt_answer = CodingPromptAnswer.new(attempt_id: @att_id,
              prompt_id: Prompt.find_by(exercise_version_id: @exercise.current_version_id).id,
              actable_id: rand(10000),
              answer: params[:exercise][:answer_code]
              )
          if prompt_answer.save!
            CodeWorker.new.async.perform( prompt_question,
              @exercise.current_version,
              @user_id,
              params[:exercise][:answer_code],
              session[:current_workout],
              @att_id,
              prompt_answer.id)
          else
            puts "IMPROPER PROMPT","IMPROPER PROMPT"
          end

        end
        if params[:wexes]
          session[:remaining_wexes] = params[:wexes]
          if params[:wexes][1..-1].count < 1
            # @wexs set to EOL if it has reached the last exercise in the
            # workout. Its is set to EOL instead of null to distinguish from
            # the latter
            @wexs = String.new('EOL')
          else
            @wexs = params[:wexes][1..-1]
          end
          # FIXME: Horrible multiple respond_to statement must be consolidated
          if params[:feedback_return]
            respond_to do |format|
              format.js
            end
            # redirect_to exercise_practice_path(@exercise,
            #   wexes: params[:wexes],
            #   feedback_return: true,att_id: @att_id),
            #   format: :js # and return
          else
            respond_to do |format|
              format.js
            end
            # redirect_to exercise_practice_path(id: params[:wexes].first,
            #   wexes: @wexs,att_id: attempt_id) and return
          end
        else
          respond_to do |format|
              format.js
          end
          #redirect_to exercise_practice_path(@exercise,
          #  feedback_return: true,att_id: attempt_id) and return
        end
      end
    else
      redirect_to exercises_url, notice: 'Choose an exercise to practice!'
    end
  end


  # -------------------------------------------------------------
  # PATCH/PUT /exercises/1
  def update
    if !user_signed_in? || (cannot? :update, @exercise)
      redirect_to root_path,
        notice: 'Unauthorized to update exercise' and return
    end
    @exercise = Exercise.find(params[:id])
    new_exercise = create_new_version()
    @exercise.base_exercise.exercises << new_exercise
    new_exercise.save
    @exercise.base_exercise.current_version = new_exercise
    @exercise.base_exercise.save
    if new_exercise.update_attributes(exercise_params)
      respond_to do |format|
        format.html do
          redirect_to new_exercise,
            notice: 'Exercise was successfully updated.'
        end
        format.json { head :no_content } # 204 No Content
      end
    else
      respond_to do |format|
        format.html { render action: 'edit' }
        format.json do
          render json: new_exercise.errors, status: :unprocessable_entity
        end
      end
    end
  end


  # -------------------------------------------------------------
  # DELETE /exercises/1
  def destroy
    if !user_signed_in? || (cannot? :destroy, @exercise)
      redirect_to root_path,
        notice: 'Unauthorized to delete exercise' and return
    end
    @exercise.destroy
    redirect_to exercises_url, notice: 'Exercise was successfully destroyed.'
  end


  #~ Private instance methods .................................................
  private

    # -------------------------------------------------------------
    # Use callbacks to share common setup or constraints between actions.
    def set_exercise
      if params[:id]
        @exercise = Exercise.find(params[:id])
      end
    end


    # -------------------------------------------------------------
    def create_new_version
      newexercise = Exercise.new
      newexercise.name = @exercise.name
      newexercise.creator_id = current_user.id
      newexercise.question = @exercise.question
      newexercise.feedback = @exercise.feedback
      newexercise.is_public = @exercise.is_public
      newexercise.mcq_allow_multiple = @exercise.mcq_allow_multiple
      newexercise.mcq_is_scrambled = @exercise.mcq_is_scrambled
      newexercise.priority =  @exercise.priority
      # TODO: Get the count of attempts from the session
      newexercise.count_attempts = 0
      newexercise.count_correct = 0
      newexercise.experience = @exercise.experience
      newexercise.version = @exercise.base_exercise.versions =
        @exercise.version + 1
      # default IRT statistics
      newexercise.difficulty = 5
      newexercise.discrimination = @exercise.discrimination
      return newexercise
    end


    # -------------------------------------------------------------
    # Only allow a trusted parameter "white list" through.
    def exercise_params
      params.require(:exercise).permit(:name, :question, :feedback,
        :experience, :id, :is_public, :priority, :type,
        :mcq_allow_multiple, :mcq_is_scrambled, :language, :area,
        choices_attributes: [:answer, :order, :value, :_destroy],
        tags_attributes: [:tag_name, :tagtype, :_destroy])
    end


    # -------------------------------------------------------------
    # should call count_submission before calling this method
    def record_attempt(score, exp)
      ex = Exercise.find(params[:id])
      attempt = Attempt.new
      if !session[:exercise_id] ||
        session[:exercise_id] != params[:id] ||
        !session[:submit_num]

        session[:exercise_id] = params[:id]
      end
      attempt.submit_num = session[:submit_num]
      attempt.submit_time = Time.now
      if ex.mcq_allow_multiple
        attempt.answer = params[:exercise][:exercise][:choice_ids].
          compact.delete_if { |x| x.empty? }
        attempt.answer = attempt.answer.join(',')
      else
        attempt.answer = params[:exercise][:exercise][:choice_ids] ||
          params[:exercise][:answer_code]
      end
      attempt.score = score
      attempt.experience_earned = exp
      attempt.user_id = current_user.id

      # wkt= Workout.find_by_sql(" SELECT * FROM workouts INNER JOIN
      #   exercise_workouts ON workouts.id = exercise_workouts.workout_id and
      #   exercise_workouts.exercise_id = #{session[:exercise_id]}")
      if session[:current_workout]
        wkt = Workout.find(session[:current_workout])
        wo = WorkoutOffering.find_by workout_id: wkt.id
        if wo
          attempt.workout_offering_id = wo.id
        end
      end
      ex.attempts << attempt
      attempt.save!
    end


    # -------------------------------------------------------------
    def record_workout_score(score, exer_id, wkt_id)
      scoring = WorkoutScore.find_by(
        user_id: current_user.id, workout_id: wkt_id)
      @current_workout = Workout.find(wkt_id)

      # FIXME: This code repeats code in code_worker.rb and needs to be
      # refactored, probably as a method (or constructor?) in WorkoutScore.
      if scoring.nil?
        scoring = WorkoutScore.new
        scoring.score = score
        scoring.last_attempted_at = Time.now
        scoring.exercises_completed = 1
        scoring.exercises_remaining = @current_workout.exercises.length - 1
        @current_workout.workout_scores << scoring
        current_user.workout_scores << scoring

      else # At least one exercise has been attempted as a part of the workout
        user_exercise_score =
          Attempt.user_attempt(current_user.id, exer_id).andand.score
        scoring.score += score
        scoring.last_attempted_at = Time.now
        if user_exercise_score
          scoring.score -= user_exercise_score
        else
          scoring.exercises_completed += 1
          scoring.exercises_remaining -= 1
          # Compensate if overshoots
          if scoring.exercises_completed > @current_workout.exercises.length
            scoring.exercises_completed = @current_workout.exercises.length
          end
          if scoring.exercises_remaining < 0
            scoring.exercises_remaining = 0
          end
          if scoring.exercises_remaining == 0
            scoring.completed = true
            scoring.completed_at = Time.now
          end
        end

      end
      scoring.save!
    end


    # -------------------------------------------------------------
    def count_submission
      if !session[:exercise_id] ||
        session[:exercise_id] != params[:id] ||
        !session[:submit_num]

        # TODO: look up only current user
        recent = Attempt.where(user_id: 1).where(exercise_id: params[:id]).
          sort_by{ |a| a[:submit_num] }
        if !recent.empty?
          session[:submit_num] = recent.last[:submit_num] + 1
        else
          session[:submit_num] = 1
        end
      else
        session[:submit_num] +=  1
      end
    end

end
