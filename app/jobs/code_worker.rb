# app/workers/code_worker.rb
require 'csv'
require 'fileutils'
require "#{Rails.root}/usr/resources/Java/java_config"

class CodeWorker
  include SuckerPunch::Job
  workers 20
  # sidekiq_options retry: false, backtrace: true

#  def perform(class_name, exid, uid, user_code, wktid, attempt_id)
#    ActiveRecord::Base.connection_pool.with_connection do
#      ex = Exercise.find(exid)
#      if !ex.current_version.prompts.first.specific.wrapper_code.blank?
#        user_code = ex.current_version.prompts.first.specific.
#          wrapper_code.sub(/___/, user_code)
  def perform(prompt_question, exercise_version, uid, user_code, wktid,attempt_id,prompt_answer_id)
    ActiveRecord::Base.connection_pool.with_connection do
      ex = exercise_version.exercise
      if !prompt_question.wrapper_code.blank?
        code_body = prompt_question.wrapper_code.sub(/___/, user_code)
      end
      current_attempt = attempt_id
      current_attempt = current_attempt.to_s
      language = ex.language


      lang =  Exercise.extension_of(language)
      # codeworkout_home=`echo $CODEWORKOUT`

      puts "CodeWorker current working directory is #{Dir.pwd}"

      term = Term.current_term
      term_name = term ? term.display_name : 'no-term'
      term_name.gsub!(/\W/, '-')
      # Create the usr/attempts dir if needed
      term_dir = 'usr/attempts/'
      if !Dir.exist?(term_dir)
        Dir.mkdir(term_dir)
      end
      # Create the term-specific folder within /usr/attempts if needed
      term_dir = term_dir + term_name
      if !Dir.exist?(term_dir)
        Dir.mkdir(term_dir)
      end
      attempt_dir = term_dir + '/' + current_attempt
      puts "DIRECTORY",attempt_dir,"DIRECTORY"
      if !Dir.exist?(attempt_dir)
        puts 'current working directory'
        puts Dir.pwd
      end
      if !Dir[attempt_dir].empty?
        puts 'WARNING, OVERWRITING EXISTING DIRECTORY'
        system "yes | rm -rf #{attempt_dir}"
      end
      Dir.mkdir(attempt_dir)
      File.open(attempt_dir + '/' + prompt_question.class_name + '.' + lang, 'w') do |f|
        f.write(code_body)
      end
      system "yes | cp -rf usr/resources/#{language}/#{prompt_question.class_name}*.#{lang} " +
        "#{attempt_dir}"

      # This "switch" based on language type needs to be refactored
      # to be more OO

        if language == "Java"
          result = execute_javatest(prompt_question.class_name, attempt_dir)
        elsif language == "Ruby"
          result = execute_rubytest(prompt_question.class_name, attempt_dir)
        elsif language == "Python"
          result = execute_pythontest(prompt_question.class_name, attempt_dir)
        end # IF INNERMOST


      correct = 0.0
      total = 0.0
      # print "RESULT",result,"RESULT"
      puts "FILE SIZE",
        File.size?(prompt_question.class_name + "_#{language}_results.csv").class
      puts "JAHAERYS", prompt_question.class_name + "_#{language}_results.csv"
      if File.size?(prompt_question.class_name + "_#{language}_results.csv").nil?
        feedback = result.split("#{prompt_question.class_name}Test")[2]
        puts "CODE-ERROR-FEEDBACK", "CODE-ERROR-FEEDBACK"
        prompt_question.test_cases.each_with_index do |tc,i|
          record_test_case_result(uid, 0.0, ex,
            "CODE-ERROR-CODE-ERROR " + feedback.to_s, i)
        end
        correct = 0.0
        total = 1.0
      else
        puts "ASSERTIONS-FEEDBACK","ASSERTIONS-FEEDBACK"
        CSV.foreach(prompt_question.class_name + "_#{language}_results.csv") do |line|
          weight = prompt_question.
            test_cases[line[2].to_i - 1].weight
          test_case_negative_feedback = prompt_question.
            test_cases[line[2].to_i - 1].negative_feedback
          correct += line[0].to_f * weight
          line[0].to_f >= 1.0 ?
            feedback = '' :
            line[1] ?
            feedback = line[1] + ' ' + test_case_negative_feedback :
            feedback = 'Test case not completely passed' +
            test_case_negative_feedback
          record_test_case_result(
            uid, line[0].to_f, prompt_question, feedback, line[2].to_i - 1,attempt_id,prompt_answer_id)
          total += weight
        end  # CSV end
      end
      record_attempt(ex, uid, user_code, wktid, correct, total, attempt_id)
      ActiveSupport::Notifications.instrument("record_#{current_attempt}_attempt", extra: :nothing) do
        puts "SKYFALL","SKYFALL","SKYFALL","SKYFALL"
     end
    end
  end


  # private methods

  private

  def record_attempt(ex, uid, user_code, wktid, correct, total_weight,aid)
    exWorkout = ExerciseWorkout.find_by(exercise_id: ex.id, workout_id: wktid)
    multiplier = exWorkout ? exWorkout.points : 1.0
    scr = correct * multiplier / total_weight
    attempt = Attempt.find(aid)
    if wktid
      attempt.workout_score_id = record_workout_score(uid, scr, ex.current_version_id, wktid)
    end
    # TODO Make the submission count dynamic
    attempt.submit_num = 1
    attempt.submit_time = Time.now
    attempt.score = scr
    # TODO Make the experience earned dynamic
    attempt.experience_earned = 10
    attempt.user_id = uid

    # wkt = Workout.find_by_sql(" SELECT * FROM workouts INNER JOIN
    #   exercise_workouts ON workouts.id = exercise_workouts.workout_id
    #   and exercise_workouts.exercise_id = #{session[:exercise_id]}")
    ex.current_version.attempts << attempt
    attempt.save!
  end


  def record_test_case_result(uid, score, prompt_question, feedback, index,att_id,prompt_answer_id)
    testcaseid = prompt_question.test_cases[index].id
    tcr = TestCaseResult.new
    tcr.user_id = uid
    if score >= 1.0
      tcr.pass = true
    else
      tcr.pass = false
    end
    tcr.execution_feedback = feedback
    tcr.coding_prompt_answer_id = prompt_answer_id
    #Attempt.find(att_id).test_case_results << tcr
    TestCase.find(testcaseid).test_case_results << tcr
    tcr.save!
  end


  def record_workout_score(uid, score, ex_version_id, wkt_id)
    scoring = WorkoutScore.find_by(user_id: uid, workout_id: wkt_id)
    current_workout = Workout.find(wkt_id)

    # FIXME: This code repeats code in code_worker.rb and needs to be
    # refactored, probably as a method (or constructor?) in WorkoutScore.
    if scoring.nil?
      scoring = WorkoutScore.new
      scoring.score = score
      scoring.last_attempted_at = Time.now
      scoring.exercises_completed = 1
      scoring.exercises_remaining = current_workout.exercises.length - 1
      current_workout.workout_scores << scoring
      User.find(uid).workout_scores << scoring
    else # At least one exercise has been attempted as a part of the workout
      scoring.score += score
      scoring.last_attempted_at = Time.now
      user_exercise_score = Attempt.find_by(user_id: uid,
        exercise_version_id: ex_version_id, workout_id: wkt_id).andand.score
      if user_exercise_score
        scoring.score -= user_exercise_score
      else
        scoring.exercises_completed += 1
        scoring.exercises_remaining -= 1
        # Compensate if overshoots
        if scoring.exercises_completed > current_workout.exercises.length
          scoring.exercises_completed = current_workout.exercises.length
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
    return scoring.id
  end


  def execute_javatest(class_name, attempt_dir)
    cmd = CodeWorkout::Config::JAVA[:compile_cmd] +
      " #{attempt_dir}/*.java " +
      ">> #{attempt_dir}/compile.log " +
      "2>> #{attempt_dir}/compile.log"
    puts "javac command = ", cmd
    if system(cmd)
      cmd = CodeWorkout::Config::JAVA[:run_cmd] +
        ":#{attempt_dir} #{class_name}TestRunner " +
        ">> #{attempt_dir}/run.log " +
        "2>> #{attempt_dir}/run.log"
      puts "java command = ", cmd
      if system(cmd)
        puts 'JAVA', 'JAVA FINE'
        return nil
      else
        return output = `cat #{attempt_dir}/run.log`
      end
    else
      return output = `cat #{attempt_dir}/compile.log`
    end
  end


  def execute_rubytest(class_name, attempt_dir)
    if system("ruby #{class_name}Test.rb",
      [:out, :err] => 'rubyerr.log',
      chdir: attempt_dir)
      puts 'FINE', 'RUBY FINE'
      return nil
    else
      puts 'ERROR', 'RUBY ERROR'
      return output = `cat #{attempt_dir}/rubyerr.log`
    end
  end


  def execute_pythontest(class_name, attempt_dir)
    if system("python #{class_name}Test.py",
      [:out, :err] => 'pythonerr.log',
      chdir: attempt_dir)
      return nil
    else
      return output = `cat #{attempt_dir}/pythonerr.log`
    end
  end

end
