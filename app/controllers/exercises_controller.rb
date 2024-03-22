class ExercisesController < ApplicationController
  require 'ims/lti'
  require 'oauth/request_proxy/rack_request'
  require 'zip'
  require 'tempfile'


  load_and_authorize_resource
  skip_authorize_resource only: [:practice, :call_open_pop, :export]

  #~ Action methods ...........................................................
  after_action :allow_iframe, only: [:practice, :embed]
  # -------------------------------------------------------------

  HTTP_URL = 'https://opendsa-server.cs.vt.edu:9292/answers/solve'


  # GET /exercises
  def index
    if current_user
      @exercises = Exercise.visible_to_user(current_user)
    else
      @exercises = Exercise.publicly_visible
    end

    @exercises = @exercises.page params[:page]
  end


  # -------------------------------------------------------------
  # The export function gets all exercises metadata for SPLICE
  # GET /gym/exercises/export
  def export
    # filter out stop/connector words for keywords from workout phrases or names
    stop_words = ['the', 'and', 'a', 'to', 'of', 'in', 'for', 'on', 'with', 'as', 'by', 'at', 'from', 'is', 'that', 'which', 'it', 'an', 'be', 'this', 'are', 'we', 'can', 'if', 'has', 'but']
    @exercises = Exercise.all
    export_data = @exercises.map do |exercise|
      workout_names = exercise.exercise_workouts.map { |ew| ew.workout.name }.uniq.push(exercise.name)
      # split phrases and remove any stop/connector words
      keywords_array = workout_names.map { |phrase| phrase.downcase.split(/\W+/) }.flatten.uniq.reject { |word| stop_words.include?(word) || word.empty? }
  
      {
        "catalog_type": "SLCItemCatalog",  
        "platform_name": "CodeWorkout",
        "url": "https://codeworkout.cs.vt.edu",
        "lti_instructions_url": "https://opendsa-server.cs.vt.edu/guides/opendsa-canvas",
        "exercise_type": Exercise::TYPE_NAMES[exercise.question_type],
        "license": "Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)",
        "description": exercise.exercise_collection&.description, # Safely fetching description
        "author": "Stephen Edwards",  
        "institution": "Virginia Tech",
        "keywords": keywords_array, 
        "exercise_name": exercise.name,
        "iframe_url": exercise.iframe_url,
        "lti_url": exercise.lti_launch_url
      }
    end
    render json: export_data
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
  def query_data
    if current_user.global_role == GlobalRole.administrator
      @available_exercises = Exercise.all.select(&:is_coding?)
    else
      @available_exercises = Exercise.visible_through_user(current_user)
        .union(Exercise.visible_through_user_group(current_user))
        .uniq.select(&:is_coding?)
    end
  end


  # -------------------------------------------------------------
  def download_attempt_data
    exercise_id = params[:id] # may be zero, one, or more ids (see Exercise.denormalized_attempt_data)
    course_id = params[:course_id]
    term_id = params[:term_id]

    time = Time.now.utc.strftime("%Y%m%d%H%M%S")

    if params[:progsnap].to_b
      main_events, code_states = Exercise.progsnap2_attempt_csv(exercise_id, course_id, term_id)
      compressed_filestream = Zip::OutputStream.write_buffer do |zos|
        main_events_file = "MainTable.csv"
        zos.put_next_entry main_events_file
        zos.write main_events

        code_states_file = "CodeStates.csv"
        zos.put_next_entry code_states_file
        zos.write code_states
      end

      compressed_filestream.rewind
      respond_to do |format|
        format.zip do
          send_data compressed_filestream.read, filename: "CW-progsnap-#{time}.zip", type: 'application/zip'
        end
      end
    else
      result = Exercise.denormalized_attempt_csv(exercise_id)

      respond_to do |format|
        format.csv do
          send_data result, filename: "CW-#{time}-submissions.csv"
        end
      end
    end
  end


  # -------------------------------------------------------------
  def search
    @terms = escape_javascript(params[:search])
    @terms = @terms.split(@terms.include?(',') ? /\s*,\s*/ : nil)
    @wos = []
    @exs = Exercise.search(@terms, current_user)
    @msg = ''
    if @exs.blank?
      @msg = "No exercises were found for the search terms: #{@terms}"
      redirect_to(exercises_path, alert: @msg) and return
    end

    respond_to do |format|
      format.html
      format.js
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
    @exercise_version = ExerciseVersion.new

    @user_groups = current_user.andand.user_groups
  end


  # -------------------------------------------------------------
  # GET /exercises/1/edit
  def edit
    puts "ResourceFile.UPLOAD_PATH = #{ResourceFile::UPLOAD_PATH}"
    @exercise_version = @exercise.current_version
    @attached_files = []
    @exercise_version.ownerships.each do |e|
      @attached_files.push({
        name: e.filename,
        url: e.resource_file.url,
        uploaded: true,
        deleted: false
      })
    end

    @text_representation = @exercise_version.text_representation ||
      ExerciseRepresenter.new(@exercise).to_hash.to_yaml
    @user_groups = current_user.user_groups
    # figure out the use/assign rights to this exercise
    if ec = @exercise.exercise_collection
      if ec.owned_by?(current_user)
        @exercise_collection = 0 # Only Me
      elsif @user_groups.include?(ec.user_group)
        @exercise_collection = ec.user_group_id
      else
        @exercise_collection = -1 # Everyone
      end
    end
    @return_to = request.referer || exercise_practice_path(@exercise)
    if @return_to.include?(exercises_search_path)
      @return_to = exercise_practice_path(@exercise)
    end
    session[:return_to] = @return_to
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

    if exercise_dump.any?
      redirect_to exercise_practice_path(exercise_dump.sample) and return
    else
      filters = []
      filters << "language #{params[:language]}" if params[:language]
      filters << "question type #{Exercise::TYPE_NAMES[params[:question_type].to_i]}" if params[:question_type]
      message = "Sorry, there are currently no public exercises #{filters.any? ? "with #{filters.to_sentence}." : "."}"
      redirect_to root_path, notice: message and return
    end
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
  def cleanFile(files, fileList)
    files.each_with_index  do |t, index|
      if !fileList.include? t.original_filename
        files = files.dup.tap { |i| i.delete_at(index) }
      end
    end
    return files
  end


  # -------------------------------------------------------------
  # POST /exercises/upload_create
  def upload_create
    if params[:exercise]
      exercise_params = params[:exercise]
      exercise_version_params = exercise_params[:exercise_version]
      use_rights = exercise_params[:exercise_collection_id].to_i
      text_representation = exercise_version_params['text_representation']
      hash = YAML.load(text_representation)
    else
      text_representation = File.read(params[:form][:file].path)
      hash = YAML.load(text_representation)
      use_rights = 0 # Personal exercise
    end
    if !hash.kind_of?(Array)
      hash = [hash]
    end

    files = exercise_params[:files]
    puts "files = #{files.inspect}"
    @attached_files = exercise_params[:attached_files]
    if @attached_files == "null"
      @attached_files = nil
    end
    if @attached_files
      @attached_files = JSON.parse(@attached_files)
    end
    puts "attached files = #{@attached_files.inspect}"

    # figure out if we need to add this to an exercise collection
    exercise_collection = nil
    if use_rights == 0
      exercise_collection = current_user.exercise_collection
      if exercise_collection.nil?
        exercise_collection = ExerciseCollection.new(
          name: "Personal exercise collection belonging to #{current_user.display_name}",
          user: current_user
        )
        exercise_collection.save!
      end
    elsif use_rights != -1 # then it must be a user group
      user_group = UserGroup.find(use_rights)
      exercise_collection = user_group.exercise_collection
      if exercise_collection.nil?
        exercise_collection = ExerciseCollection.new(
          name: "Exercise collection for the #{user_group.name} group",
          user_group: user_group
        )
        exercise_collection.save!
      end
    end

    @return_to = session.delete(:return_to) || exercises_path

    # parse the text_representation
    exercises = ExerciseRepresenter.for_collection.new([]).from_hash(hash)
    success_all = true
    error_msgs = []
    success_msgs = []
    exercises.each do |e|
      if !e.save
        success_all = false
        # put together an error message
        error_msgs <<  "Errors while saving exercise #{e.andand.name}:<ul>"
        e.errors.full_messages.each do |msg|
          error_msgs << "<li>#{msg}</li>"
        end
        error_msgs << "</ul>"
      else # successfully created the exercise
        ex_ver = e.current_version

        # make the current user an exercise owner if they aren't already
        e.add_owner!(current_user)

        # copy all retained resource files, skipping any to be removed
        prev_version = e.exercise_versions.offset(1).first
        if prev_version
          puts "processing ownerships from prev version #{prev_version.id}"
          prev_version.ownerships.each do |o|
            puts "checking ownership #{o.inspect}"
            # Double-loop isn't the greatest design, but both lists are short
            @attached_files.each do |a|
              puts "checking against attachment #{a.inspect}"
              # uploaded flag is true if it was previously uploaded
              # deleted flag is true if it is to be pruned/removed from exercise
              if a['name'] == o.filename && a['uploaded'] && !a['deleted']
                puts "adding ownership record"
                ownertable = ex_ver.ownerships.create!(
                  filename: o.filename,
                  resource_file: o.resource_file)
              end
            end
          end
        end
        # Now add all newly uploaded attached files
        if files
          files.each do |file|
            puts "processing new upload #{file.inspect}"
            @attached_files.each do |a|
              puts "checking against attachment #{a.inspect}"
              if a['name'] == file.original_filename && !a['uploaded'] && !a['deleted']
                Ownership.create!(
                  filename: file.original_filename,
                  exercise_version: ex_ver,
                  resource_file: ResourceFile.for_upload(file, current_user)
                )
              end
            end
          end
        end

        # Add exercise to collection
        exercise_collection.andand.add(e, override: true)

        # Update the text representation
        e.current_version.update(text_representation: text_representation)

        # Notify user of success
        success_msgs <<
          "<li>X#{e.id}: #{e.name} saved</li>"
      end
    end

    if success_all
      success_msgs = '<ul>' + success_msgs.join("") + '</ul>'
      redirect_to @return_to, flash: { success: success_msgs.html_safe } and return
    else
      if !success_msgs.blank?
        error_msgs << 'Some exercises were successfully saved.'
        error_msgs << '<ul>' + success_msgs.join('') + '</ul>'
      end
      redirect_to @return_to, flash: { error: error_msgs.join("").html_safe } and return
    end
  end


  # -------------------------------------------------------------
	def embed
    if params[:exercise_version_id] || params[:id]
      set_exercise_from_params
    else
      @message = 'Choose an exercise to embed!'
      render 'lti/error' and return
    end

    redirect_to exercise_practice_path(id: @exercise.id, lti_launch: true) and return
	end


  # -------------------------------------------------------------
  def practice
    # lti launch
    @lti_launch = params[:lti_launch]

    if params[:exercise_version_id] || params[:id]
      set_exercise_from_params
    else
      @message = 'Choose an exercise to practice!'
      if @lti_launch
        render 'lti/error' and return
      else
        redirect_to exercises_url, notice: @message and return
      end
    end

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

    if @workout_offering
      # Re-check workout-offering permission in case the URL was entered directly.
      authorize! :practice, @workout_offering
      authorize! :practice, @exercise
    elsif !@workout
      # are they trying to practice the exercise in the gym?
      authorize! :gym_practice, @exercise
    end

    @attempt = nil
    @workout_score = params[:workout_score_id] ? WorkoutScore.find(params[:workout_score_id]) : (
      @workout_offering ? @workout_offering.score_for(@student_user) : (
          @workout ? @workout.score_for(@student_user, @workout_offering) : nil
    ))

    if @student_user
      @student_user.current_workout_score = @workout_score ? @workout_score : nil
      @student_user.save!
    end

    if @workout_offering && @workout_score &&
      @workout_score.workout_offering != @workout_offering
      @workout_score = nil
    end

    if @workout_offering && !@workout_score
      @workout_score = @workout_offering.score_for(@student_user)
    end

    if @workout_score
      if @workout_score.lis_result_sourcedid.nil? && @workout_score.lis_outcome_service_url.nil?
        @workout_score.lis_result_sourcedid = params[:lis_result_sourcedid]
        @workout_score.lis_outcome_service_url = params[:lis_outcome_service_url]

        @workout_score.save

        # we set LMS gradebook ties for the first time, so force-send scores to LMS
        @workout_score.update_lti if @workout_score.score
      end

      should_force_lti = !@lti_launch &&
        @workout_offering.andand.lms_assignment_id.present? &&
        (@workout_score.andand.lis_result_sourcedid.nil? ||
          @workout_score.andand.lis_outcome_service_url.nil?)

      if should_force_lti && !current_user.manages?(@workout_offering.course_offering)
        @message = "This assignment must be accessed through your course's " +
          "Learning Management System (like Canvas)."
        @redirect_url = @workout_offering.lms_assignment_url
        render 'lti/error' and return
      end

      @attempts_left = @workout_score
        .attempts_left_for_exercise_version(@exercise_version)
    end

    @workout ||= @workout_score ? @workout_score.workout : nil
    manages_course = current_user.andand.global_role.andand.is_admin? ||
      @workout_offering.andand.course_offering.andand.is_manager?(current_user)

    if !manages_course && @workout_score.andand.closed? &&
      @workout_offering.andand.workout_policy.andand.no_review_before_close &&
      !@workout_offering.andand.shutdown?
      path = root_path
      if @workout_offering
        path = organization_workout_offering_path(
            organization_id:
              @workout_offering.course_offering.course.organization.slug,
            course_id: @workout_offering.course_offering.course.slug,
            term_id: @workout_offering.course_offering.term.slug,
            id: @workout_offering.id)
      elsif @workout
        path = workout_path(@workout)
      end
      redirect_to path,
        notice: "The time limit has passed for this workout." and return
    end

    @msg = nil
    @user_deadline = nil
    student_review = false
    if @user_time_limit
      if @workout_score.andand.closed?
        @msg = 'The time limit has passed. This assignment is closed and no ' +
          'longer accepting submissions.'
        student_review = true
      else
        start_time = @workout_score ? @workout_score.started_at : Time.zone.now
        @user_deadline = start_time + @user_time_limit.minutes
        if @workout_offering.hard_deadline_for(current_user)
          @user_deadline = [@user_deadline,
            @workout_offering.hard_deadline_for(current_user)].min
        end
        @user_deadline = @user_deadline.to_s
        @user_deadline = @user_deadline.split(" ")[0] + "T" + @user_deadline.split(" ")[1]
        @server_now = Time.zone.now.to_s
        @server_now = @server_now.split(" ")[0] + "T" + @server_now.split(" ")[1]
        @msg = 'Time remaining - ##:##'
      end
    elsif @workout_offering && !@workout_offering.andand.can_be_practiced_by?(current_user)
      @msg = 'This assignment is now closed and no longer accepting submissions.'
      student_review = true
    end

    # display the scored attempt if in review mode (for students or instructors)
    if @workout_score
      @attempt = (params[:review_user_id] || student_review) ?
        @workout_score.scoring_attempt_for(@exercise_version.exercise) :
        @workout_score.previous_attempt_for(@exercise_version.exercise)
    end

    if @workout.andand.exercise_workouts.andand.where(
      exercise: @exercise).andand.any?
      @max_points = @workout.exercise_workouts.
        where(exercise: @exercise).first.points
    end

    @responses = ['There are no responses yet!']
    @explain = ['There are no explanations yet!']

    # safety code to prune long session data
    if session[:leaf_exercises] && session[:leaf_exercises].length > 5
      session[:leaf_exercises].shift(session[:leaf_exercises].length - 5)
    end

    # Only add exercise to leaf list if this isn't part of a workout
    @workout ||= @workout_score.andand.workout ||
      @workout_offering.andand.workout
    if !@workout
      if session[:leaf_exercises]
        if session[:leaf_exercises] && session[:leaf_exercises].length >= 5
          session[:leaf_exercises].shift(1)
        end
        session[:leaf_exercises] << @exercise.id
      else
        session[:leaf_exercises] = [@exercise.id]
      end
    end
    # EOL stands for end of line
    # @wexs is the variable to hold the list of exercises of this workout
    # yet to be attempted by the user apart from the current exercise

    if params[:wexes] != 'EOL'
      @wexs = params[:wexes] || session[:remaining_wexes]
    else
      @wexs = nil
    end

		# decide whether or not to hide the sidebar
		# hide it if this workout (if present) has less than two exercises
		ex_count = @workout.andand.exercises.andand.count
    @hide_sidebar = (!@workout && @lti_launch) || (ex_count && ex_count < 2)
    # Updata image tags in the exercise question
    @exercise_version.image_processing(true)
    # Display all files to students
    @file_res = @exercise_version.file_processing
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
    @lti_launch = params[:lti_launch]

		if params[:exercise_version_id] || params[:id]
      set_exercise_from_params
    else
      @message = 'Choose an exercise to evaluate!'
      if @lti_launch
        render 'lti/error' and return
      else
        redirect_to exercises_url,
          notice: 'Choose an exercise to practice!' and return
      end
    end

    if current_user
      @student_drift_user = current_user
    elsif session[:student_drift_user_id]
      @student_drift_user = User.find(session[:student_drift_user_id])
    else
      user_ip = request.remote_ip.clone()
      fake_email = user_ip.clone().gsub('.','') + Time.now.to_i.to_s + '@cw.edu'
      fake_password = Time.now.to_i.to_s + user_ip.clone().gsub('.','')
      @student_drift_user = User.new(email: fake_email, slug: fake_email,
                              password: fake_password,
                              current_sign_in_ip: request.remote_ip,
                              last_sign_in_ip: request.remote_ip,
                              global_role_id: 4)
      @student_drift_user.save!
      session[:student_drift_user_id] = @student_drift_user.id
    end
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
    if @workout_offering.nil? &&
      @student_drift_user.andand.current_workout_score &&
      @student_drift_user.current_workout_score.workout.contains?(
        @exercise_version.exercise)
      @workout_offering = @student_drift_user.current_workout_score.workout_offering
      if @workout_offering.nil?
        @workout = @student_drift_user.current_workout_score.workout
      end
    end

    if @workout.nil?
      if @workout_offering
        @workout = @workout_offering.workout
      elsif params[:workout_id]
        @workout = Workout.find_by(id: params[:workout_id])
      end
    end

    if @workout.nil? && session[:current_workout]
      @workout = Workout.find_by(id: session[:current_workout])
      if !@workout.contains?(@exercise_version.exercise)
        @workout = nil
      end
    end

    @workout_score = nil

    if @workout_offering
      @workout_score = @workout_offering.score_for(@student_drift_user)
    elsif @workout
      @workout_score = @workout.score_for(@student_drift_user, nil,
                                          params[:lis_outcome_service_url],
                                          params[:lis_result_sourcedid])
    end

    # Has the allotted time for the workout offering passed?
    if @workout_score.andand.closed? &&
      !@workout_offering.andand.can_be_practiced_by?(@student_drift_user)
      p 'WARNING: attempt to evaluate exercise after time expired.'
      return
    end

    @attempts_left = @workout_score ?
      @workout_score.attempts_left_for_exercise_version(@exercise_version)
      : nil
    if current_user &&
      !current_user.is_staff?(@workout_offering.andand.course_offering) &&
      @attempts_left &&
      @attempts_left <= 0
      p 'WARNING: attempt to evaluate workout_offering after attempts expired.'
      return
    end

    # update the in-memory count of attempts_left, so it is represented
    # in the partial
    @attempts_left = (@attempts_left && @attempts_left > 0) ?
      @attempts_left - 1 : @attempts_left
    @attempt = @exercise_version.new_attempt(
      user: @student_drift_user, workout_score: @workout_score)

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
      # using count_submission()
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
      if @is_perfect
        flash.notice = "Your previous question's answer choice has been saved and scored"
        if @workout_score.andand.workout_offering
          @workout_offering = @workout_score.workout_offering
          render :js => "window.location = '" +
            organization_workout_offering_practice_path(
            exercise_id: @workout_score.workout.next_exercise(@exercise),
            organization_id: @workout_offering.course_offering.course.organization.slug,
            course_id: @workout_offering.course_offering.course.slug,
            term_id: @workout_offering.course_offering.term.slug,
            id: @workout_offering.id,
            lti_launch: @lti_launch) + "' "
        elsif @workout_score.andand.workout
          render :js => "window.location = '" +
            exercise_practice_path(
              @workout_score.workout.next_exercise(@exercise),
              workout_id: @workout_score.workout.id,
              workout_score_id: @workout_score.andand.id,
              lti_launch: @lti_launch) + "' "
        end
      end
    elsif @exercise_version.is_coding?
      @answer_code = params[:exercise_version][:answer_code]
      @exercise_version.prompts.each_with_index do |exercise_prompt, i|
        exercise_prompt_answer = @attempt.prompt_answers[i]
        exercise_prompt_answer.answer = params[:exercise_version][:answer_code]
        if exercise_prompt_answer.save
          CodeWorker.new.async.perform(@attempt.id)
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


  # -------------------------------------------------------------
  # OpenPOP support
  def call_open_pop
    require 'rest-client'
    require 'json'
    payload = {'exercise_id' => params[:exercise_id].strip,
               'code' => params[:code].strip
    }

    request = RestClient::Request.execute(:method => :post,
                                            :url => HTTP_URL,
                                            :payload => payload.to_json,
                                            :headers => {'Content-Type' => 'application/json'},
					    :verify_ssl => OpenSSL::SSL::VERIFY_NONE)
    trace = JSON.parse(request.body)
    @openpop_results = trace

    curr_user = nil
    unless current_user.nil?
      curr_user = current_user
    end
    workout_id = nil
    if(params[:workoutID] != '')
      workout_id = Workout.find(params[:workoutID])
    end
    workout_offering_id = nil
    if(params[:workoutOfferingID] != '')
      workout_offering_id = WorkoutOffering.find(params[:workoutOfferingID])
    end
    @visualization_logging = VisualizationLogging.new(
      user: curr_user,
      exercise: Exercise.find_by_name(params[:exercise_id]),
      workout: workout_id,
      workout_offering: workout_offering_id
    )
    @visualization_logging.save
    respond_to do |format|
      format.json { render :json => trace }  # note, no :location or :status options
    end

  end


  #~ Private instance methods .................................................
  private

    # set @exercise and @exercise_version based on params
    # ----------------------------------------------------------
    def set_exercise_from_params
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
        :experience, :id, :is_public, :priority, :question_type,
        :exercise_version, :exercise_version_id, :commit,
        :mcq_allow_multiple, :mcq_is_scrambled, :languages, :styles,
        :tag_ids, {files: []})
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
