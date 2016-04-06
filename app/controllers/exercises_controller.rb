class ExercisesController < ApplicationController
  load_and_authorize_resource


  #~ Action methods ...........................................................

  # -------------------------------------------------------------
  # GET /exercises
  def index
    @exercises = Exercise.where(is_public: true)
  end


  # -------------------------------------------------------------
  # GET /exercises/download.csv
  def download
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
#    @wos = Workout.search @terms
    @wos = []
    @exs = Exercise.search(@terms, current_user)
    @msg = ''
#    if @wos.length == 0 && @exs.length == 0
    if @exs.length == 0
      @msg = 'No exercises were found for your search request. ' \
        'Try these instead...'
#      @wos = Workout.order('RANDOM()').limit(4)
      @exs = Exercise.order('RANDOM()').limit(16)
    end
    if @exs.length == 0
      @msg = 'No public exercises are available to search right now. ' \
        'Wait for contributors to add more.'
    end
  end


  # -------------------------------------------------------------
  # GET /exercises/1
  def show
  end


  # -------------------------------------------------------------
  # GET /exercises/new
  def new
    @exercise = Exercise.new
    # @coding_exercise = CodingQuestion.new
    # @languages = Tag.where(tagtype: Tag.language).pluck(:tag_name)
    # @areas = Tag.where(tagtype: Tag.area).pluck(:tag_name)
  end


  # -------------------------------------------------------------
  # GET /exercises/1/edit
  def edit
  end


  # -------------------------------------------------------------
  # POST /exercises
  def create
    ex = Exercise.new
    exercise_version = ExerciseVersion.new(exercise: ex)
    msg = params[:exercise] || params[:coding_question]
    msg[:is_public] = msg[:is_public].to_i > 0
    form_hash = msg.clone()
    arr = []
    form_hash["current_version"] = msg[:exercise_version].clone()
    if msg[:question_type].to_i == 2
      msg[:coding_prompt].merge!(msg[:prompt])
      test_cases = ""
      msg[:coding_prompt][:test_cases_attributes].values.each do |tc|
        test_cases = test_cases + tc.values.join(",") + "\n"
      end
      test_cases.rstrip!
      msg[:coding_prompt].delete("test_cases_attributes")
      msg[:coding_prompt]["tests"] = test_cases
      form_hash["current_version"]["prompts"] = Array.new
      codingprompt = {"coding_prompt" => msg[:coding_prompt].clone()}
      form_hash["current_version"]["prompts"] << codingprompt
      form_hash.delete("coding_prompt")
    elsif msg[:question_type].to_i == 1
      msg[:multiple_choice_prompt].merge!(msg[:prompt])
      msg[:multiple_choice_prompt][:is_scrambled] = msg[:multiple_choice_prompt][:is_scrambled].to_i > 0
      msg[:multiple_choice_prompt][:allow_multiple] = msg[:allow_multiple].to_i > 0
      form_hash["current_version"]["prompts"] = Array.new
      msg[:multiple_choice_prompt]["choices"] = msg[:multiple_choice_prompt]["choices"].values
      multiplechoiceprompt = {"multiple_choice_prompt" => msg[:multiple_choice_prompt].clone()}
      form_hash["current_version"]["prompts"] << multiplechoiceprompt
      form_hash.delete("multiple_choice_prompt")
    end
    form_hash.delete("prompt")
    form_hash.delete("exercise_version")
    form_hash.delete("question_type")
    arr << form_hash
    exercises = ExerciseRepresenter.for_collection.new([]).from_hash(arr)
    if exercises[0].save!
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
    Exercise.where(is_public: true).each do |exercise|
      if params[:language] ?
        (exercise.language == params[:language]) :
        params[:question_type] ?
        (exercise.question_type == params[:question_type].to_i) :
        true

        exercise_dump << exercise
      end
    end
    redirect_to exercise_practice_path(exercise_dump.sample) and return
  end


  # -------------------------------------------------------------
  # POST exercises/create_mcqs
  def create_mcqs
    CSV.foreach(params[:form].fetch(:mcqfile).path, {headers: true}) do |row|
      if row['Question'].include?('Python')
        next
      end
      exercise = Exercise.new(external_id: row['ID'])
      exercise.is_public = false
      exercise.language = ''
    end
  end# def


  # -------------------------------------------------------------
  # GET exercises/upload_mcqs
  def upload_mcqs
  end


  # -------------------------------------------------------------
  # GET exercises/upload_exercises
  def upload
  end


  # -------------------------------------------------------------
  def upload_yaml
  end


  # -------------------------------------------------------------
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
      end

    end
    redirect_to exercises_path
  end


  # -------------------------------------------------------------
  # POST /exercises/upload_create
  def upload_create
    hash = YAML.load(File.read(params[:form][:file].path))
    exercises = ExerciseRepresenter.for_collection.new([]).from_hash(hash)
    exercises.each do |e|
      if !e.save
        # FIXME: Add these to alert message that can be sent back to user
        puts 'cannot save exercise, name = ' + e.name.to_s +
          ', external_id = ' + e.external_id.to_s + ': ' +
          e.errors.full_messages.to_s
        if e.current_version
          puts "    #{e.current_version.errors.full_messages.to_s}"
          if e.current_version.prompts.any?
            puts "    #{e.current_version.prompts.first.errors.full_messages.to_s}"
          end
        end
      end
    end

    redirect_to exercises_url, notice: 'Exercise upload complete.'
  end


  # -------------------------------------------------------------
  # GET/POST /practice/1
  def practice
    if params[:exercise_version_id]
      @exercise_version =
        ExerciseVersion.find_by(id: params[:exercise_version_id])
      if !@exercise_version
        redirect_to exercises_url, notice:
          "Exercise version EV#{params[:exercise_version_id]} " +
          "not found" and return
      end
      @exercise = @exercise_version.exercise
    elsif params[:id]
      @exercise = Exercise.find_by(id: params[:id])
      if !@exercise
        redirect_to exercises_url,
          notice: "Exercise E#{params[:id]} not found" and return
      end
      @exercise_version = @exercise.current_version
    else
      redirect_to exercises_url,
        notice: 'Choose an exercise to practice!' and return
    end
    # Tighter restrictions for the moment, should go away
    authorize! :practice, @exercise

    @student_user = params[:review_user_id] ? User.find(params[:review_user_id]) : current_user

    if params[:workout_offering_id]
      @workout_offering =
        WorkoutOffering.find_by(id: params[:workout_offering_id])
      @workout = @workout_offering.workout
      if @workout_offering.time_limit_for(@student_user)
        @user_time_limit = @workout_offering.time_limit_for(@student_user)
      else
        @user_time_limit = nil
      end
    else
      @workout_offering = nil
      if params[:workout_id]
        @workout = Workout.find(params[:workout_id])
      end
    end

    @attempt = nil
    @workout_score = @workout_offering ? @student_user.current_workout_score :
      @workout ? @workout.score_for(@student_user, @workout_offering) : nil
    if @workout_offering &&
      @workout_score.workout_offering != @workout_offering
      @workout_score = nil
    end
    if @workout_offering && !@workout_score
      @workout_score = @workout_offering.score_for(@student_user)
    end
    if @workout_score
      @attempt = @workout_score.attempt_for(@exercise_version.exercise)
    end
    @workout ||= @workout_score ? @workout_score.workout : nil
    if @workout_score.andand.closed? &&
      @workout_offering.andand.workout_policy.andand.no_review_before_close &&
      !@workout_offering.andand.shutdown?
      path = root_path
      if @workout_offering
        path = organization_workout_offering_path(
            organization_id:
              @workout_offering.course_offering.course.organization.slug,
            course_id: @workout_offering.course_offering.course.slug,
            term_id: @workout_offering.course_offering.term.slug,
            workout_offering_id: @workout_offering.id)
      elsif @workout
        path = workout_path(@workout)
      end
      redirect_to path,
        notice: "The time limit has passed for this workout." and return
    end

    if @workout.andand.exercise_workouts.andand.where(exercise: @exercise).andand.any?
      @max_points = @workout.exercise_workouts.
        where(exercise: @exercise).first.points
      puts "\nMAX-POINTS", @max_points, "\nMAX-POINTS"
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
    render layout: 'two_columns'
  end


  # -------------------------------------------------------------
  def create_choice
    @ans = Choice.create
    @pick.push()
  end


  # -------------------------------------------------------------
  #GET /evaluate/1
  def evaluate
    # Copy/pasted from #practice method.  Should be refactored.

    if params[:exercise_version_id]
      @exercise_version =
        ExerciseVersion.find_by(id: params[:exercise_version_id])
      if !@exercise_version
        redirect_to exercises_url, notice:
          "Exercise version EV#{params[:exercise_version_id]} " +
          "not found" and return
      end
      @exercise = @exercise_version.exercise
    elsif params[:id]
      @exercise = Exercise.find_by(id: params[:id])
      if !@exercise
        redirect_to exercises_url,
          notice: "Exercise E#{params[:id]} not found" and return
      end
      @exercise_version = @exercise.current_version
    else
      redirect_to exercises_url,
        notice: 'Choose an exercise to practice!' and return
    end

    if @exercise_version.is_mcq?
      if Attempt.find_by(user: current_user, exercise_version: @exercise_version)
        flash.notice = "You can't re-attempt MCQs"
        return
      end
    end
    # Tighter restrictions for the moment, should go away
    authorize! :practice, @exercise
    @workout = nil
    @workout_offering = nil
    if params[:workout_offering_id]
      @workout_offering =
        WorkoutOffering.find_by(id: params[:workout_offering_id])
      if @workout_offering &&
        !@workout_offering.workout.contains?(@exercise_version.exercise)
        @workout_offering = nil
      end
    else
      @workout_offering = nil
    end
    if @workout_offering.nil? && current_user.andand.current_workout_score &&
      current_user.current_workout_score.workout.contains?(@exercise_version.exercise)
      @workout_offering = current_user.current_workout_score.workout_offering
      if @workout_offering.nil?
        @workout = current_user.current_workout_score.workout
      end
    end
    if @workout_offering && @workout.nil?
      @workout = @workout_offering.workout
    end
    if @workout.nil? && session[:current_workout]
      @workout = Workout.find_by(id: session[:current_workout])
      if !@workout.contains?(@exercise_version.exercise)
        @workout = nil
      end
    end
    @workout_score = nil
    if @workout_offering
      @workout_score = @workout_offering.score_for(current_user)
    elsif @workout
      @workout_score = @workout.score_for(current_user)
    end
    if @workout_score.andand.closed? && @workout_offering.andand.can_be_practiced_by?(current_user)
      p 'WARNING: attempt to evaluate exercise after time expired.'
      return
    end
    @attempt = @exercise_version.new_attempt(
      user: current_user, workout_score: @workout_score)

    @attempt.save!
    # FIXME: Need to make it work for multiple prompts
    # prompt = @exercise_version.prompts.first.specific
    # prompt_answer = @attempt.prompt_answers.first  # already specific here
    if @workout.andand.exercise_workouts.andand.where(exercise: @exercise).andand.any?
      @max_points = @workout.exercise_workouts.
        where(exercise: @exercise).first.points
    else # case when exercise being practised is not part of any workout
      @max_points = 10.0
    end
    if @exercise_version.is_mcq?
      if params[:exercise_version]
        # Usual single prompt question
        response_ids = params[:exercise_version][:choice][:id]
      else
        # Multi-prompt questions
        prompt_keys = params.keys.select{|key| key.include?("prompt-") }
        response_ids = prompt_keys.map{|prompt_key| params[prompt_key] }

        prompt_keys.each_with_index do |prompt_key, i|
          @attempt.prompt_answers[i].choices << Choice.find(response_ids[i])
        end
      end

      p params
      @responses = Array.new
      if response_ids.class == Array
        # Remove blank responses and duplicates
        response_ids.reject!(&:blank?)
        response_ids.uniq!
        response_ids.compact!
        # FIXME: Assumes no multi-choice answers
        response_ids.each do |r|
          @responses.push(Choice.find(r))
        end
      else
        @responses.push(Choice.find(response_ids))
      end

      @responses.compact!
      @responses.each do |answer|
        answer[:answer] = markdown(answer[:answer])
      end

      # recording the answer choices
      # FIXME: Only temporary
      if params[:exercise_version]
        @attempt.prompt_answers.first.choices = @responses
      end

      @score = @exercise_version.score(@responses)
      if @workout
        @score = @score * @max_points / @exercise_version.max_mcq_score
      end
      # TODO: Enable @explain and @exercise_feedback again
      #@explain = @exercise_version.collate_feedback(@responses)
      @exercise_feedback = 'You have attempted exercise '
      # + "#{@exercise.id}:#{@exercise.name}" +
      #  ' and its feedback for you: ' +
      #  @explain.to_sentence

      # TODO: calculate experience based on correctness and num submissions
      count_submission()
      @xp = @exercise_version.mcq_experience_on(@responses, @attempt.submit_num)

      @attempt.score = @score
      @attempt.feedback_ready = true
      @attempt.experience_earned = @xp
      @attempt.save!
      if @workout_score
        @workout_score.record_attempt(@attempt)
      end

      if @max_points <= @attempt.score ||
        !@workout_score.andand.show_feedback?
        @is_perfect = true
      end
      if @is_perfect && @workout_score.andand.workout
        flash.notice = "Your previous question's answer choice has been saved and scored"
        render :js => "window.location = '" +
          organization_workout_offering_practice_path(
          exercise_id: @workout_score.workout.next_exercise(@exercise, current_user, nil),
          organization_id: @workout_offering.course_offering.course.organization.slug,
          course_id: @workout_offering.course_offering.course.slug,
          term_id: @workout_offering.course_offering.term.slug,
          id: @workout_offering.id) + "' "
      end
    elsif @exercise_version.is_coding?
      @answer_code = params[:exercise_version][:answer_code]
      # Why were these in here? what purpose do they serve ??????
      # ---
      # @answer_code.gsub!("\r","")
      # @answer_code.gsub!("\n","")
      @exercise_version.prompts.each_with_index do |exercise_prompt, i|
        exercise_prompt_answer = @attempt.prompt_answers[i]
        exercise_prompt_answer.answer = params[:exercise_version][:answer_code]
        if exercise_prompt_answer.save
          CodeWorker.new.async.perform(
            @attempt.id,
            @workout_score.andand.id)
        else
          puts 'IMPROPER PROMPT',
            'unable to save prompt_answer: ' \
            "#{prompt_answer.errors.full_messages.to_s}",
            'IMPROPER PROMPT'
        end
      end
      @workout ||= @workout_score.andand.workout
    end

  end


  # -------------------------------------------------------------
  # PATCH/PUT /exercises/1
  def update
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
    @exercise.destroy
    redirect_to exercises_url, notice: 'Exercise was successfully destroyed.'
  end


  #~ Private instance methods .................................................
  private

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
        :experience, :id, :is_public, :priority, :question_type,
        :exercise_version, :exercise_version_id, :commit,
        :mcq_allow_multiple, :mcq_is_scrambled, :languages, :styles,
        :tag_ids)
    end


    # -------------------------------------------------------------
    def count_submission
      if !session[:exercise_id] ||
        session[:exercise_id] != params[:id] ||
        !session[:submit_num]

        # TODO: look up only current user
        recent = Attempt.where(user_id: 1).where(
          exercise_version_id: params[:exercise_version_id]).
          sort_by { |a| a[:submit_num] }
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
