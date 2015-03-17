class ExercisesController < ApplicationController
  include ExercisesHelper
  require 'action_view/helpers/javascript_helper'
  require 'nokogiri'
  require 'csv'
  include ActionView::Helpers::JavaScriptHelper


  before_action :set_exercise, only: [:show, :edit, :update, :destroy]
  respond_to :html, :js, :json

  # GET /exercises
  def index
    if cannot? :index, Exercise
      redirect_to root_path,
        notice: 'Unauthorized to view all exercises' and return
    end
    @exercises = Exercise.all
  end


  # GET /exercises/download.csv
  def download
    if cannot? :index, Exercise
      redirect_to root_path,
        notice: 'Unauthorized to view all exercises' and return
    end
    @exercises = Exercise.all

    respond_to do |format|
      format.csv
    end
  end


  def search
    searched = escape_javascript(params[:search])
    @wos = Workout.search searched
    @exs = Exercise.search searched
    if(@wos.length + @exs.length > 0)
      @msg = ""
    else
      @msg = "No " + searched + " exercises found. Try these instead..."
      @wos = Workout.order("RANDOM()").limit(4)
      @exs = Exercise.order("RANDOM()").limit(16)
    end
    render layout: 'two_columns'
  end


  # GET /exercises/1
  def show
  end


  # GET /exercises/new
  def new
    @exercise = Exercise.new
    @coding_exercise = CodingQuestion.new
    @languages = Tag.where(tagtype: Tag.language).pluck(:tag_name)
    @areas = Tag.where(tagtype: Tag.area).pluck(:tag_name)
  end


  # GET /exercises/1/edit
  def edit
  end


  # POST /exercises
  def create
    basex=BaseExercise.new
    ex=Exercise.new
    msg = params[:exercise] || params[:coding_question]
    basex.user_id = current_user.id
    basex.question_type = msg[:question_type] || 1
    basex.versions = 1
    ex.title = msg[:title].chomp.strip
    # ex.question = ERB::Util.html_escape(msg[:question])
    # ex.feedback = ERB::Util.html_escape(msg[:feedback])
    ex.question = msg[:question]
    ex.feedback = msg[:feedback]

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
    basex.current_version = ex.id
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


  def random_exercise
    exercise_dump = []
    if params[:language]
      BaseExercise.all.each do |baseexercise|
        candidate_exercise = Exercise.find_by_id(baseexercise.current_version)
        if candidate_exercise &&
          candidate_exercise.language == params[:language] &&
          candidate_exercise.id >= 200
          exercise_dump << candidate_exercise
        elsif !candidate_exercise
          puts "ERROR: base exercise #{baseexercise.id} with current " +
            "version #{baseexercise.current_version} does not refer to " +
            "an existing exercise."
        end # INNER IF
      end   # DO WHILE

    elsif params[:question_type]
      BaseExercise.where(question_type: params[:question_type].to_i).
        find_each do |baseexercise|
        print 'BASE EXERCISE', baseexercise.id, 'BASE EXERCISE'
        candidate_exercise = Exercise.find_by_id(baseexercise.current_version)
        if candidate_exercise && candidate_exercise.id >= 0
          exercise_dump << candidate_exercise
        elsif !candidate_exercise
          puts "ERROR: base exercise #{baseexercise.id} with current " +
            "version #{baseexercise.current_version} does not refer to " +
            "an existing exercise."
        end # INNER IF
      end   # DO WHILE
    else
      BaseExercise.all.each do |baseexercise|
        candidate_exercise = Exercise.find_by_id(baseexercise.current_version)
        if candidate_exercise && candidate_exercise.id >= 200
          exercise_dump << candidate_exercise
        elsif !candidate_exercise
          puts "ERROR: base exercise #{baseexercise.id} with current " +
            "version #{baseexercise.current_version} does not refer to " +
            "an existing exercise."
        end # INNER IF
      end   # DO WHILE
    end #OUTER IF
    redirect_to exercise_practice_path(exercise_dump.sample) and return
  end


  # POST exercises/create_mcqs
  def create_mcqs
    basex = BaseExercise.new
    basex.user_id = current_user.id
    basex.question_type = msg[:question_type] || 1
    basex.versions = 1
    csvfile = params[:form]
    puts csvfile.fetch(:xmlfile).path
    CSV.foreach(csvfile.fetch(:xmlfile).path) do |question|
      if $INPUT_LINE_NUMBER > 1
        title_ex = question[1]
        # priority_ex=question[2]
        question_ex = question[3][3..-5]

        if question[15] && question[15].include?("p")
          gradertext_ex = question[15][3..-5]
        else
          gradertext_ex = ''
        end

        if question[5] && question[6] &&
          question[5][3..-5] && question[6][3..-5]
          ex = Exercise.new
          ex.title = title_ex
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

          ex.user_id = current_user.id
          ex.experience = 10

          # default IRT statistics
          ex.difficulty = 0
          ex.discrimination = 0
          ex.version = 1
          basex.exercises << ex
          ex.save!
          basex.current_version = ex.id
          basex.save

          #   i = 0
          #  right = 0.0
          # total = 0.0
          alphanum = {'A' => 1, 'B' => 2, 'C' => 3, 'D' => 4, 'E' => 5,
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
      end
    end
    redirect_to exercises_url, notice: 'Uploaded!'
  end


  # GET exercises/upload_mcqs
  def upload_mcqs
  end


  # GET exercises/upload_exercises
  def upload_exercises
  end


  # POST /exercises/upload_create
  def upload_create
    basex = BaseExercise.new
    basex.user_id = current_user.id
    basex.question_type = msg[:question_type] || 1
    basex.versions = 1
    questionfile = params[:form]
    doc = Nokogiri::XML(File.open(questionfile.fetch(:xmlfile).path))
    questions = doc.xpath('/quiz/question')
    questions.each do |question|
      ex = Exercise.new
      title_ex = question.xpath('./name/text')[0].content
      question_ex = question.xpath('./questiontext/text')[0].content
      if !question.xpath('.//generalfeedback/text').empty?
        feedback_ex = question.xpath('.//generalfeedback/text')[0].content
      else
        feedback_ex = ''
      end

      if !question.xpath('.//defaultgrade').empty?
        priority_ex = question.xpath('.//defaultgrade')[0].content
      else
        priority_ex = 1.to_s
      end

      if !question.xpath('.//penalty').empty?
        discrimination_ex = question.xpath('.//penalty')[0].content
      else
        discrimination_ex = 0.to_s
      end

      if !question.xpath('.//graderinfo').empty?
        gradertext_ex = question.xpath('.//graderinfo/text')[0].content
      else
        gradertext_ex = ''
      end
      # TODO: Sanitize the uploads
      ex.title = title_ex
      ex.question = question_ex
      ex.feedback = feedback_ex
      ex.is_public = true
      ex.mcq_allow_multiple = false
      ex.mcq_is_scrambled = false
      ex.priority = priority_ex
      # TODO: Get the count of attempts from the session
      ex.count_attempts = 1
      ex.count_correct = 1
      ex.user_id = current_user.id
      ex.experience = 20

      # default IRT statistics
      ex.difficulty = 5
      ex.discrimination = discrimination_ex
      ex.version = 1
      basex.exercises << ex
      ex.save!
      basex.current_version=ex.id
      basex.save
    end
    redirect_to exercises_url, notice: 'Uploaded!'
  end


  # GET/POST /practice/1
  def practice
    if params[:id]
      found = Exercise.where(:id => params[:id])
      if found.empty?
        redirect_to exercises_url, notice: "Exercise #{params[:id]} not found"
      elsif user_signed_in?
        @exercise = found.first
        @answers = @exercise.serve_choice_array
        @responses = ["There are no responses yet!"]
        @explain = ["There are no explanations yet!"]
        @ex_attempt = Exercise.new

        # EOL stands for end of line
        # @wexs is the variable to hold the list of exercises of this workout yet to be attempted by the user apart from the current exercise
        if params[:wexes] != "EOL"
          @wexs = params[:wexes] || session[:remaining_wexes]
        else
          @wexs = nil
        end
      else
        redirect_to exercise_path(found.first),
          notice: "Need to login to practice" and return
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


  def create_choice
    @ans = Choice.create
    @pick.push()
  end


  #GET /evaluate/1
  def evaluate
    if params[:id]
      found = Exercise.where(id: params[:id])
      if found.empty?
        redirect_to exercises_url, notice: "Exercise #{params[:id]} not found"
      else
        @exercise = found.first
        if @exercise.base_exercise.question_type == 1
          response_ids = params[:exercise][:exercise][:choice_ids]
          p params
          @responses = Array.new
          if @exercise.mcq_allow_multiple
            response_ids.each do |r|
              @responses.push(Choice.where(id: r).first)
            end
          else
            @responses.push(Choice.where(id: response_ids).first)
          end
          @responses = @responses.compact
          @responses.each do |answer|
            answer[:answer] = CGI::unescapeHTML(answer[:answer]).html_safe
          end
          @score = @exercise.score(@responses)
          if session[:current_workout]
            @score = @score * ExerciseWorkout.findExercisePoints(
              @exercise.id, session[:current_workout])
          end
          @explain = @exercise.collate_feedback(@responses)
          @exercise_feedback = 'You have attempted exercise ' +
            "#{@exercise.id}:#{@exercise.title}" +
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
        elsif @exercise.base_exercise.question_type == 2
          CodeWorker.new.async.perform(@exercise.coding_question.class_name,
            @exercise.id,
            current_user.id,
            params[:exercise][:answer_code],
            session[:current_workout])
          # TODO: This sleep call is a broken approach to turning the
          # async processing into a synchronous call, since feedback is
          # pulled from the client via an ajax call.  This needs to be
          # removed, and instead feedback results need to be sent using
          # HTML5 server-side push
          sleep(3.0)
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
          if params[:feedback_return]
            redirect_to exercise_practice_path(@exercise,
              wexes: params[:wexes],
              feedback_return: true),
              format: :js # and return
          else
            redirect_to exercise_practice_path(id: params[:wexes].first,
              wexes: @wexs) and return
          end
        else
          # Move as to display the exercise submission feedback
          redirect_to exercise_practice_path(@exercise,
            feedback_return: true), format: :js and return
        end
      end
    else
      redirect_to exercises_url, notice: 'Choose an exercise to practice!'
    end
  end

  # PATCH/PUT /exercises/1
  def update
    @exercise = Exercise.find(params[:id])
    new_exercise = create_new_version()
    @exercise.base_exercise.exercises<<new_exercise;
    new_exercise.save
    @exercise.base_exercise.current_version=new_exercise.id
    @exercise.base_exercise.save
    if new_exercise.update_attributes(exercise_params)
      respond_to do |format|
        format.html { redirect_to new_exercise, notice: 'Exercise was successfully updated.' }
        format.json { head :no_content } # 204 No Content
      end
    else
      respond_to do |format|
        format.html { render action: "edit" }
        format.json { render json: new_exercise.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /exercises/1
  def destroy
    @exercise.destroy
    redirect_to exercises_url, notice: 'Exercise was successfully destroyed.'
  end


  private

    # Use callbacks to share common setup or constraints between actions.
    def set_exercise
      if params[:id]
        @exercise = Exercise.find(params[:id])
      end
    end


    def create_new_version
      newexercise = Exercise.new
      newexercise.title = @exercise.title
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


    # Only allow a trusted parameter "white list" through.
    def exercise_params
      params.require(:exercise).permit(:title, :question, :feedback,
        :experience, :id, :is_public, :priority, :type,
        :mcq_allow_multiple, :mcq_is_scrambled, :language, :area,
        choices_attributes: [:answer, :order, :value, :_destroy],
        tags_attributes: [:tag_name, :tagtype, :_destroy])
    end


    def make_html(unescaped)
      return CGI::unescapeHTML(unescaped.to_s).html_safe
    end


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
          compact.delete_if{ |x| x.empty? }
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
