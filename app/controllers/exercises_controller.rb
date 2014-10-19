class ExercisesController < ApplicationController
  require 'action_view/helpers/javascript_helper'
  require 'nokogiri'
  require 'csv'
  include ActionView::Helpers::JavaScriptHelper

  before_action :set_exercise, only: [:show, :edit, :update, :destroy]

  # GET /exercises
  def index
    @exercises = Exercise.all
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

    ex.user_id = current_user.id

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

def create_mcqs
  csvfile = params[:form]  
  puts csvfile.fetch(:xmlfile).path
  puts "HINTER"
  CSV.foreach(csvfile.fetch(:xmlfile).path) do |question|
    if $INPUT_LINE_NUMBER > 1
      puts "Line Number ",  $INPUT_LINE_NUMBER
      title_ex=question[1]
      puts "TITLE",title_ex
    #priority_ex=question[2]
      question_ex=question[3][3..-5]

      if (!question[15].nil? && question[15].include?("p"))
      gradertext_ex=question[15][3..-5]
      else
      gradertext_ex=""
      end


            
      if ( !question[5].nil? && !question[6].nil? &&  !question[5][3..-5].nil? && !question[6][3..-5].nil?)
        ex = Exercise.new
   
        ex.question_type = 1
        ex.title = title_ex
        ex.question = question_ex 
        ex.feedback = gradertext_ex 
        ex.is_public = true
        
        #if msg[:is_public] == 0
         # ex.is_public = false
        #end
        
        ex.mcq_allow_multiple = true
        
        #if msg[:mcq_allow_multiple].nil?
         # ex.mcq_allow_multiple = false
        #end
        
        ex.mcq_is_scrambled = true
        #if msg[:mcq_is_scrambled].nil?
         # ex.mcq_is_scrambled = false
        #end
        ex.priority = 1
        ex.count_attempts = 5
        ex.count_correct = 1
        #ex.language_id=1
      


        ex.user_id = current_user.id

        ex.experience = 10
      
    
        #default IRT statistics
        ex.difficulty = 0
        ex.discrimination = 0
        ex.save!
        
     #   i = 0
      #  right = 0.0
       # total = 0.0
        alphanum = {"A"=>1,"B"=>2,"C"=>3,"D"=>4,"E"=>5,"F"=>6,"G"=>7,"H"=>8,"I"=>9,"J"=>10}  
        choices=[]        
        choice1=question[5][3..-5]
        choices<<choice1
        choice2=question[6][3..-5]
        choices<<choice2        
        if (!question[7].nil? && question[7].include?("p"))
          choice3=question[7][3..-5]
          choices<<choice3
        end
        if (!question[8].nil? && question[8].include?("p"))
          choice4=question[8][3..-5]
          choices<<choice4
        end
        if (!question[9].nil? && question[9].include?("p"))
          choice5=question[9][3..-5]
          choices<<choice5
        end
        if (!question[10].nil? && question[10].include?("p"))
          choice6=question[10][3..-5]
          choices<<choice6
        end
        if (!question[11].nil? && question[11].include?("p"))
          choice7=question[11][3..-5]
          choices<<choice7
        end
        if (!question[12].nil? && question[12].include?("p"))
          choice8=question[12][3..-5]
          choices<<choice8
        end
        if (!question[13].nil? && question[13].include?("p"))
          choice9=question[13][3..-5]
          choices<<choice9
        end
        if (!question[14].nil? && question[14].include?("p"))
          choice10=question[14][3..-5]
          choices<<choice10
        end
        cnt=0;
        choices.each do |choiceitem|
          ch = Choice.create
          ch.answer = choiceitem
          cnt=cnt+1
          puts "CHOICE",choiceitem,ch
          if( alphanum[question[5]] == cnt )
            ch.value = 1
          else
            ch.value = -1
          end

          ch.feedback = gradertext_ex
          ch.order = cnt
          ex.choices << ch
          #ch.exercise << @exercise
          ch.save!
        end
      
      else
      puts "INVALID Question"
      puts "INVALID choice",choice1
      puts "INVALID choice",choice2
      end
    end
  end
  redirect_to exercises_url, notice: "Uploaded!"
end
  
  
def upload_mcqs  
end

def upload_exercises
end
# POST /exercises/upload_create
  def upload_create
    
    questionfile = params[:form]
      
  doc=Nokogiri::XML(File.open(questionfile.fetch(:xmlfile).path));
  questions=doc.xpath('/quiz/question');

  questions.each do |question|
  ex = Exercise.new
  title_ex    = question.xpath('./name/text')[0].content
  question_ex = question.xpath('./questiontext/text')[0].content
  if !question.xpath('.//generalfeedback/text').empty?
     feedback_ex = question.xpath('.//generalfeedback/text')[0].content
  else 
     feedback_ex = ""
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
    gradertext_ex=question.xpath('.//graderinfo/text')[0].content
  else 
     gradertext_ex = ""
  end
    
    
    ex.question_type = 2
    ex.title = title_ex
    ex.question = question_ex
    ex.feedback = feedback_ex
    ex.is_public = true
    ex.mcq_allow_multiple = false
    ex.mcq_is_scrambled = false
    ex.priority =  priority_ex
    ex.count_attempts = 1
    ex.count_correct = 1

    ex.user_id = current_user.id
   
    ex.experience = 20
          
    #default IRT statistics
    ex.difficulty = 5
    ex.discrimination = discrimination_ex

    ex.save!
    end
    redirect_to exercises_url, notice: "Uploaded!"
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