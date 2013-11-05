class ExercisesController < ApplicationController
  before_action :set_exercise, only: [:show, :edit, :update, :destroy]

  # GET /exercises
  def index
    @exercises = Exercise.all
  end

  def search
    @results = Exercise.search params[:search]

    render layout: 'two_columns'
  end

  # GET /exercises/1
  def show
  end

  # GET /exercises/new
  def new
    @exercise = Exercise.new
    #@pick = Array.new(2, Choice.new) #start with 2 choices by default
    #@pick.each do |choice|
    #  @exercise.choices << choice
    #@ans = Choice.new
    @languages = Tag.where(:tagtype => Tag.language).pluck(:tag_name)
    @areas = Tag.where(:tagtype => Tag.area).pluck(:tag_name)
    #end
  end

  # GET /exercises/1/edit
  def edit
  end

  # POST /exercises
  def create
    ex = Exercise.new
    msg = params[:exercise]
    ex.question_type = 1
    ex.title = msg[:title]
    ex.question = ERB::Util.html_escape(msg[:question])
    ex.feedback = ERB::Util.html_escape(msg[:feedback])
    ex.is_public = true
    if msg[:is_public] == 0
      ex.is_public = false
    end
    ex.mcq_allow_multiple = true
    if msg[:mcq_allow_multiple].nil?
      ex.mcq_allow_multiple = false
    end
    ex.mcq_is_scrambled = true
    if msg[:mcq_is_scrambled].nil?
      ex.mcq_is_scrambled = false
    end
    ex.priority = 0
    ex.count_attempts = 0
    ex.count_correct = 0
    if msg[:language_id]
      ex.language_id = msg[:language_id].to_i
    end

    #TODO get user id from session data
    ex.user_id = 1

    if( msg[:experience] )
      ex.experience = msg[:experience]
    else
      ex.experience = 10
    end
    
    #default IRT statistics
    ex.difficulty = 0
    ex.discrimination = 0

    ex.save!
    i = 0
    right = 0.0
    total = 0.0

    #typed in tags
    msg[:tags_attributes].each do |t|
      Tag.tag_this_with(ex, t.second["tag_name"].to_s, Tag.skill)
    end

    #selected tags
    msg[:tag_ids].delete_if(&:empty?)
    msg[:tag_ids].each do |tag_name|
      Tag.tag_this_with(ex, tag_name.to_s, Tag.misc)
    end

    msg[:choices_attributes].each do |c|
      if c.second["value"] == "1"
        right = right + 1
      end
      total = total + 1
    end
    msg[:choices_attributes].each do |c|
      tmp = Choice.create
      tmp.answer = ERB::Util.html_escape(c.second[:answer])
      if( c.second["value"] == "1" )
        tmp.value = right/total*100
      else
        tmp.value = -(total-right)/total*100
      end

      tmp.feedback = ERB::Util.html_escape(c.second[:feedback])
      tmp.order = i
      ex.choices << tmp
      #tmp.exercise << @exercise
      tmp.save!
      
      i=i+1
    end

    if ex.save!
      redirect_to ex, notice: 'Exercise was successfully created.'
    else
      #render action: 'new'
      redirect_to ex, notice: "Exercise was NOT created for #{msg} #{@exercise.errors.messages}"
    end
  end

  # GET/POST /practice/1
  def practice
    if( params[:id] )
      found = Exercise.where(:id => params[:id])
      if( found.empty? )
        redirect_to exercises_url, notice: "Exercise #{params[:id]} not found"
      else
        @exercise = found.first
        @answers = @exercise.serve_choice_array
        @responses = ["There are no responses yet!"]
        @explain = ["There are no explanations yet!"]
      end
    else
      redirect_to exercises_url, notice: 'Choose an exercise to practice!'
    end
    render layout: 'two_columns'
  end

  def create_choice
    @ans = Choice.create
    @pick.push()
  end

  #GET /practice/1
  def evaluate
    if( params[:id] )
      found = Exercise.where(:id => params[:id])
      if( found.empty? )
        redirect_to exercises_url, notice: "Exercise #{params[:id]} not found"
      else
        @exercise = found.first
        response_ids = params[:exercise][:choice_ids]
        @responses = Array.new
        if( @exercise.mcq_allow_multiple )
          response_ids.each do |r|
            @responses.push( Choice.where(:id => r).first )
          end
        else
          @responses.push( Choice.where(:id => response_ids).first )
        end
        @responses = @responses.compact
        @responses.each do |answer|
          answer[:answer] = CGI::unescapeHTML(answer[:answer]).html_safe
        end

        @score = @exercise.score(@responses)
        @explain = @exercise.collate_feedback(@responses)
        #TODO calculate experience based on correctness and how many submissions
        count_submission()
        @xp = @exercise.experience_on(@responses,session[:submit_num])
        record_attempt(@score,@xp)

        render layout: 'two_columns'
      end
    else
      redirect_to exercises_url, notice: 'Choose an exercise to practice!'
    end
  end

  # PATCH/PUT /exercises/1
  def update
    if @exercise.update(exercise_params)
      redirect_to @exercise, notice: 'Exercise was successfully updated.'
    else
      render action: 'edit'
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
      if( params[:id] )
        @exercise = Exercise.find(params[:id])
      end
    end

    # Only allow a trusted parameter "white list" through.
    def exercise_params
      #params[:exercise]
      params.permit(:title, :question, :feedback, :is_public, :priority, :type,
        :mcq_allow_multiple, :mcq_is_scrambled, :language, :area,
        choices_attributes: [:answer,:order,:value,:_destroy],
        tags_attributes: [:tag_name,:tagtype,:_destroy])
    end

    def make_html(unescaped)
      return CGI::unescapeHTML(unescaped.to_s).html_safe
    end

    #~ should call count_submission before calling this method
    def record_attempt(score,exp)
      attempt = Attempt.create
      if( !session[:exercise_id] || 
          session[:exercise_id] != params[:id] ||
          !session[:submit_num] )
        session[:exercise_id] = params[:id]
      end
      attempt.submit_num = session[:submit_num]
      attempt.submit_time = Time.now
      attempt.answer = params[:exercise][:choice_ids].compact.delete_if{|x| x.empty?}
      attempt.answer = attempt.answer.join(",")
      attempt.score = score
      attempt.experience_earned = exp
      #TO DO tie attempt to current user session
      attempt.user_id = 1
      ex = Exercise.find(params[:id])
      ex.attempts << attempt
      attempt.save!      
    end

    def count_submission
      if( !session[:exercise_id] || 
          session[:exercise_id] != params[:id] ||
          !session[:submit_num] )
        #TO DO look up only current user
        recent = Attempt.where(:user_id => 1).where(:exercise_id => params[:id]).sort_by{|a| a[:submit_num]}
        if( !recent.empty? )
          session[:submit_num] = recent.last[:submit_num] + 1
        else
          session[:submit_num] = 1
        end
      else
        session[:submit_num] = session[:submit_num] + 1
      end
    end
end