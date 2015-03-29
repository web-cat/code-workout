# app/workers/code_worker.rb
require 'csv'
require 'fileutils'

class CodeWorker
  include SuckerPunch::Job
  workers 20
  # sidekiq_options retry: false, backtrace: true

  def perform(class_name, exid, uid, user_code, wktid)
    ActiveRecord::Base.connection_pool.with_connection do
      ex = Exercise.find(exid)
      if !ex.coding_question.wrapper_code.blank?
        user_code = ex.coding_question.wrapper_code.sub(/___/, user_code)
      end
      current_attempt = Attempt.maximum('id') + 1
      current_attempt = current_attempt.to_s
      language = ex.language

      # code_body = ex.coding_question.wrapper_code.sub('___',user_code)
      code_body = user_code
      lang =  Exercise.extension_of(language)
      # codeworkout_home=`echo $CODEWORKOUT`

      puts "CodeWorker current working directory is #{Dir.pwd}"

      term = Term.current_term
      term_name = term ? term.display_name : 'no-term'
      term_name.gsub!(/\W/, '-')
      term_dir = 'usr/attempts/' + term_name
      if !Dir.exist?(term_dir)
        Dir.mkdir(term_dir)
      end
      attempt_dir = term_dir + '/' + current_attempt
      if !Dir.exist?(attempt_dir)
        Dir.mkdir(attempt_dir)
      end
      if !Dir[current_attempt].empty?
        puts 'WARNING, OVERWRITING EXISTING DIRECTORY'
        system "yes | rm -rf #{current_attempt}"
      end

      File.open(attempt_dir + '/' + class_name + '.' + lang, 'w') do |f|
        f.write(code_body)
      end
      system "yes | cp -rf usr/resources/#{language}/#{class_name}*.#{lang} " +
        "#{attempt_dir}"

      # This "switch" based on language type needs to be refactored
      # to be more OO
      if language == "Java"
        result = execute_javatest(class_name, attempt_dir)
      elsif language == "Ruby"
        result = execute_rubytest(class_name, attempt_dir)
      elsif language == "Python"
        result = execute_pythontest(class_name, attempt_dir)
      end # IF INNERMOST

      correct = 0.0
      total = 0.0
      # print "RESULT",result,"RESULT"
      puts "FILE SIZE",
        File.size?(class_name + "_#{language}_results.csv").class
      if File.size?(class_name + "_#{language}_results.csv").nil?
        feedback = result.split("#{class_name}Test")[2]
        puts "CODE-ERROR-FEEDBACK", "CODE-ERROR-FEEDBACK"
        ex.coding_question.test_cases.each_with_index do |tc,i|
          record_test_case_result(uid, 0.0, ex,
            "CODE-ERROR-CODE-ERROR " + feedback.to_s, i)
        end
        correct = 0.0
        total = 1.0
      else
        puts "ASSERTIONS-FEEDBACK","ASSERTIONS-FEEDBACK"
        CSV.foreach(class_name + "_#{language}_results.csv") do |line|
          weight = ex.coding_question.
            test_cases[line[2].to_i - 1].weight
          test_case_negative_feedback = ex.coding_question.
            test_cases[line[2].to_i - 1].negative_feedback
          correct += line[0].to_f * weight
          line[0].to_f >= 1.0 ?
            feedback = '' :
            line[1] ?
            feedback = line[1] + ' ' + test_case_negative_feedback :
            feedback = 'Test case not completely passed' +
            test_case_negative_feedback
          record_test_case_result(
            uid, line[0].to_f, ex, feedback, line[2].to_i - 1)
          total += weight
        end  # CSV end
      end

      record_attempt(ex, uid, user_code, wktid, correct, total)
    end
  end


  # private methods

  private

  def record_attempt(ex, uid, user_code, wktid, correct, total_weight)
    exWorkout = ExerciseWorkout.find_by(exercise_id: ex.id, workout_id: wktid)
    multiplier = exWorkout ? exWorkout.points : 1.0
    scr = correct * multiplier / total_weight
    if wktid
      record_workout_score(uid, scr, ex.id, wktid)
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

    # wkt = Workout.find_by_sql(" SELECT * FROM workouts INNER JOIN
    #   exercise_workouts ON workouts.id = exercise_workouts.workout_id
    #   and exercise_workouts.exercise_id = #{session[:exercise_id]}")
    if wktid
      wkt = Workout.find(wktid)
      wo = WorkoutOffering.find_by workout_id: wkt.id
      if wo
        attempt.workout_offering_id = wo.id
      end
    end
    ex.attempts << attempt
    attempt.save!
  end


  def record_test_case_result(uid, score, ex, feedback, index)
    testcaseid = ex.coding_question.test_cases[index].id
    tcr = TestCaseResult.new
    tcr.user_id = uid
    if score >= 1.0
      tcr.pass = true
    else
      tcr.pass = false
    end
    tcr.execution_feedback = feedback
    TestCase.find(testcaseid).test_case_results << tcr
    tcr.save!
  end


  def record_workout_score(uid, score, exer_id, wkt_id)
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
      user_exercise_score = Attempt.user_attempt(uid, exer_id).andand.score
      scoring.score += score
      scoring.last_attempted_at = Time.now
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
  end


  def execute_javatest(class_name, attempt_dir)
    classpath = Dir['usr/resources/Java/*.jar'].join(':')
    cmd = "javac -cp #{classpath} #{attempt_dir}/*.java " +
      ">> #{attempt_dir}/compile.log " +
      "2>> #{attempt_dir}/compile.log"
    puts "javac command = ", cmd
    if system(cmd)
      cmd = "java -cp #{classpath}:#{attempt_dir} #{class_name}TestRunner " +
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
