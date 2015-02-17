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
    language = @excercise.language
    
    #code_body = @excercise.coding_question.wrapper_code.sub('___',user_code)
    code_body = user_code
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
            if !Dir[current_attempt].empty?
              puts "WARNING, OVERWRITING EXISTING DIRECTORY"
              system "yes | rm -rf #{current_attempt}/"
            end
            Dir.mkdir(current_attempt)  
            puts "SIDEKIQ current working directory is #{Dir.pwd}"
            system "yes | cp -rf ../#{base_class}*.#{lang} #{current_attempt}"
            Dir.chdir(current_attempt) do              
              puts "SIDEKIQ current working directory is #{Dir.pwd}"
              if language == "Java"
                result = execute_javatest(base_class)
              elsif language == "Ruby"
                result = execute_rubytest(base_class)
              elsif language == "Python" 
                result = execute_pythontest(base_class)
              end # IF INNERMOST
              correct=total=0.0
              #print "RESULT",result,"RESULT"
              puts "FILE SIZE",File.size?(base_class+"_#{language}_results.csv").class
              if (File.size?(base_class+"_#{language}_results.csv").nil?)
                feedback=result.split("#{base_class}Test")[2]
                puts "CODE-ERROR-FEEDBACK","CODE-ERROR-FEEDBACK"
                @excercise.coding_question.test_cases.each_with_index do |tc,i|
                  record_test_case_result(uid,0.0,exid,"CODE-ERROR-CODE-ERROR "+feedback.to_s,i)  
                end
                correct=0.0
                total=1.0
              else
                puts "ASSERTIONS-FEEDBACK","ASSERTIONS-FEEDBACK"
                CSV.foreach(base_class+"_#{language}_results.csv") do |line|
                  weight   = @excercise.coding_question.test_cases[line[2].to_i-1].weight
                  test_case_negative_feedback=@excercise.coding_question.test_cases[line[2].to_i-1].negative_feedback
                  correct+=line[0].to_f * weight
                  line[0].to_f >= 1.0 ? feedback = '' : line[1] ? feedback = line[1]+ ' '+ test_case_negative_feedback : feedback = 'Test case not completely passed' + test_case_negative_feedback    
                  record_test_case_result(uid,line[0].to_f,exid,feedback,line[2].to_i-1)
                  total+=weight
                end  # CSV end
              end
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
    if system("javac #{base_class}.java #{base_class}Test.java #{base_class}TestRunner.java  >> javaerr.log 2>>javaerr.log")
      if system("java #{base_class}TestRunner")
        puts "JAVA","JAVA FINE"    
        return nil
      else
        return output=`cat javaerr.log`  
      end
    else
      return output=`cat javaerr.log`
    end  
  end
  
  def execute_rubytest(base_class)
    if system("ruby #{base_class}Test.rb >> rubyerr.log 2>>rubyerr.log")
      puts "FINE","RUBY FINE"
      return nil
    else
      puts "ERROR","RUBY ERROR"
      return output=`cat rubyerr.log`
    end
  end
  
  def execute_pythontest(base_class)
    if system ("python #{base_class}Test.py > pythonerr.log 2>>pythonerr.log")
      return nil
    else
      return output=`cat pythonerr.log`  
    end
  end
end