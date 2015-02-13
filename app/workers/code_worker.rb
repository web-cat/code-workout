#app/workers/code_worker.rb
require 'csv'
require 'fileutils'

class CodeWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true
  
  LANGUAGE_EXTENSION={
    'Ruby' => 'rb',
    'Java' => 'java',
    'Python' => 'py',
    'Shell' => 'sh'
  }
  
  def perform(base_class,exid,uid,user_code,wktid)
    @excercise=Exercise.find(exid)
    current_attempt = Attempt.maximum("id")+1
    current_attempt = current_attempt.to_s
    #Determine the programming language of the exercise from its main language tag
    exercise_tags = @excercise.tags.to_ary
    language = ''
    exercise_tags.each do |tag|
      if tag.tagtype == Tag.language
        language = tag.tag_name
        break
      end
    end
    
    code_body = @excercise.coding_question.wrapper_code.sub('___',user_code)
    lang =  LANGUAGE_EXTENSION[language]
    #codeworkout_home=`echo $CODEWORKOUT`
    
    puts "SIDEKIQ current working directory is #{Dir.pwd}"
    
    File.open('usr/resources/'+base_class+'.'+lang, "wb") { |f| f.write( code_body ) }
    current_term = nil
    Dir.chdir("usr/resources") do
      Term.all.each do |term|
        if term.now?
          current_term_name = term.display_name
          Dir.chdir(current_term_name) do
            if Dir[current_attempt].empty? 
              Dir.mkdir(current_attempt)
            else
              puts "WARNING, OVERWRITING EXISTING DIRECTORY"
            end  
            puts "SIDEKIQ current working directory is #{Dir.pwd}"
            system "yes | cp -rf ../#{base_class}*.#{lang} #{current_attempt}"
            Dir.chdir(current_attempt) do              
              puts "SIDEKIQ current working directory is #{Dir.pwd}"
              if language == "Java"
                execute_javatest(base_class)
              elsif language == "Ruby"
                execute_rubytest(base_class)
              elsif language == "Python" 
                execute_pythontest(base_class)
              end # IF INNERMOST
              correct=total=0.0
              CSV.foreach(base_class+"_#{language}_results.csv") do |line|
                weight   = @excercise.coding_question.test_cases[line[2].to_i-1].weight
                test_case_negative_feedback=@excercise.coding_question.test_cases[line[2].to_i-1].negative_feedback
                correct+=line[0].to_f * weight
                line[0].to_f >= 1.0 ? feedback = '' : line[1] ? feedback = line[1]+ ' '+ test_case_negative_feedback : feedback = 'Test case not completely passed' + test_case_negative_feedback    
                record_test_case_result(uid,line[0].to_f,exid,feedback,line[2].to_i-1)
                total+=weight
              end  # CSV end
              record_attempt(exid,uid,user_code,wktid,correct,total)                            
            end    # CHDIR LAST
          end # CHDIR TERM
        end # IF
        
      end # Term loop
    end   # CHDIR usr/resources


    
    
       
    
  end
  
  #prive methods
  private
  def record_attempt(exid,uid,user_code,wktid,correct,total_weight)
    ex = Exercise.find(exid)
    ExerciseWorkout.find_by(exercise_id: exid,workout_id: wktid) ? multiplier = ExerciseWorkout.find_by(exercise_id: exid,workout_id: wktid).points : multiplier = 1.0
    scr = correct * multiplier / total_weight
    if wktid
      record_workout_score(uid,scr,exid,wktid)
    end
    attempt = Attempt.new
    # TODO Make the submission count dynamic
    attempt.submit_num = 1
    attempt.submit_time = Time.now
    attempt.answer = user_code  
    attempt.score = scr
    # TODO Make the experience earned dynamic
    attempt.experience_earned = 10
    attempt.user_id = uid
      
    #wkt= Workout.find_by_sql(" SELECT * FROM workouts INNER JOIN exercise_workouts ON workouts.id = exercise_workouts.workout_id and exercise_workouts.exercise_id = #{session[:exercise_id]}")
    if wktid      
      wkt=Workout.find(wktid)
      wo=WorkoutOffering.find_by workout_id: wkt.id
      if wo
        attempt.workout_offering_id=wo.id
      end
    end
    ex.attempts << attempt
    attempt.save!
  end
  
  def record_test_case_result(uid,score,exer_id,feedback,index)
    ex=Exercise.find(exer_id)
    testcaseid = ex.coding_question.test_cases[index].id
    tcr = TestCaseResult.new
    tcr.user_id = uid
    if score>=1.0
      tcr.pass = true
    else
      tcr.pass = false
    end  
    tcr.execution_feedback=feedback
    TestCase.find(testcaseid).test_case_results<<tcr
    tcr.save!
  end
  
  def record_workout_score(uid,score,exer_id,wkt_id)
    scoring = WorkoutScore.find_by(user_id: uid, workout_id: wkt_id)
    current_workout=Workout.find(wkt_id)
    if scoring.nil?
      scoring=WorkoutScore.new
      scoring.score=score
      scoring.last_attempted_at = Time.now
      scoring.exercises_completed=1
      scoring.exercises_remaining=current_workout.exercises.length-1
      current_workout.workout_scores<<scoring
      User.find(uid).workout_scores<<scoring
    else #Atleast one exercise has been attempted as a part of the workout         
      user_exercise_score=Attempt.user_attempt(uid, exer_id)
      scoring.score += score       
      scoring.last_attempted_at = Time.now            
      if user_exercise_score 
        scoring.score -= user_exercise_score
      else
        scoring.exercises_completed += 1
        scoring.exercises_remaining -= 1
        # Compensate if overshoots          
        if scoring.exercises_completed > current_workout.exercises.length    
          scoring.exercises_completed       = current_workout.exercises.length
        end
        if scoring.exercises_remaining < 0 
          scoring.exercises_remaining = 0
        end
        if scoring.exercises_remaining == 0
          scoring.completed=true
          scoring.completed_at = Time.now
        end
      end             
    end      
    scoring.save!
  end  
  
  def execute_javatest(base_class)
      system "javac #{base_class}.java #{base_class}Test.java #{base_class}TestRunner.java"
      system "java #{base_class}TestRunner"    
  end
  
  def execute_rubytest(base_class)
    system "ruby #{base_class}Test.rb"
  end
  
  def execute_pythontest(base_class)
    system "python #{base_class}Test.py"
  end
end