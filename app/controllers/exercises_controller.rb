class ExercisesController < ApplicationController
  before_action :set_exercise, only: [:show, :edit, :update, :destroy]

  # GET /exercises
  def index
    @exercises = Exercise.all
  end

  # GET /exercises/1
  def show
  end

  # GET /exercises/new
  def new
    @exercise = Exercise.new
    @pick5 = Array.new(5, Choice.new)
    @pick5.each do |choice|
      @exercise.choices << choice
    end
    #@exercise.choices << choice
  end

  # GET /exercises/1/edit
  def edit
  end

  # POST /exercises
  def create
    @exercise = Exercise.new
    msg = params[:exercise]
    @exercise.question_type = 1
    @exercise.title = msg[:title]
    @exercise.question = ERB::Util.html_escape(msg[:question])
    @exercise.feedback = ERB::Util.html_escape(msg[:feedback])
    @exercise.is_public = true
    if msg[:is_public] == 0
      @exercise.is_public = false
    end
    @exercise.mcq_allow_multiple = true
    if msg[:mcq_allow_multiple].nil?
      @exercise.mcq_allow_multiple = false
    end
    @exercise.mcq_is_scrambled = true
    if msg[:mcq_is_scrambled].nil?
      @exercise.mcq_is_scrambled = false
    end
    @exercise.priority = 0
    @exercise.count_attempts = 0
    @exercise.count_correct = 0
    lang = msg[:language].downcase
    lid = Language.where(:name => lang)
    if lid.empty?
      l = Language.create
      l.name = lang
      l.save
      @exercise.language << l
    else
      @exercise.language = lid.first
    end

    #TODO get user id from session data
    @exercise.user_id = 1

    if msg[:difficulty] == "Novice"
      @exercise.difficulty = 1
    elsif msg[:difficulty] == "Easy"
      @exercise.difficulty = 2
    elsif msg[:difficulty] == "Moderate"
      @exercise.difficulty = 3
    elsif msg[:difficulty] == "Difficult"
      @exercise.difficulty = 4
    elsif msg[:difficulty] == "Expert"
      @exercise.difficulty = 5
    else
      @exercise.difficulty = 1
    end

    @exercise.discrimination = 0

    @exercise.save!
    i = 0
    msg[:choices_attributes].each do |c|
      tmp = Choice.create
      tmp.answer = ERB::Util.html_escape(c.second[:answer])
      tmp.value = c.second[:value]
      tmp.feedback = ERB::Util.html_escape(c.second[:feedback])
      tmp.order = i
      @exercise.choices << tmp
      #tmp.exercise << @exercise
      tmp.save!
      
      i=i+1
    end

    if @exercise.save!
      redirect_to @exercise, notice: 'Exercise was successfully created.'
    else
      #render action: 'new'
      redirect_to @exercise, notice: "Exercise was NOT created for #{msg} #{@exercise.errors.messages}"
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
      end
    else
      redirect_to exercises_url, notice: 'Choose an exercise to practice!'
    end
  end

  #GET /practice/1
  def evaluate
    if( params[:id] )
      found = Exercise.where(:id => params[:id])
      if( found.empty? )
        redirect_to exercises_url, notice: "Exercise #{params[:id]} not found"
      else
        @exercise = found.first
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
      @exercise = Exercise.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def exercise_params
      #params[:exercise]
      params.permit(:title, :question, :feedback, :is_public, :priority, :type,
        :mcq_allow_multiple, :mcq_is_scrambled, :choices)
    end
#      #MCQ-specific columns, using single-table inheritance:
#      t.boolean   :mcq_allow_multiple
#      t.boolean   :mcq_is_scrambled
end