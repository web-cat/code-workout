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
  def perform(exercise_version_id, user_id, workout_id, attempt_id)
    ActiveRecord::Base.connection_pool.with_connection do
      exv = ExerciseVersion.find(exercise_version_id)
      prompt = exv.prompts.first.specific
      attempt = Attempt.find(attempt_id)
      if !prompt.wrapper_code.blank?
        code_body = prompt.wrapper_code.sub(/\b___\b/,
        attempt.prompt_answers.first.specific.answer)
      end
      current_attempt = attempt_id
      current_attempt = current_attempt.to_s
      language = exv.exercise.language


      lang =  Exercise.extension_of(language)
      # codeworkout_home=`echo $CODEWORKOUT`

      puts "CodeWorker current working directory is #{Dir.pwd}"

      term = Term.current_term
      term_name = term ? term.slug : 'no-term'
      attempt_dir = 'usr/attempts/' + term_name + '/' + current_attempt
      puts "DIRECTORY",attempt_dir,"DIRECTORY"
      FileUtils.mkdir_p(attempt_dir)
      if !Dir[attempt_dir].empty?
        puts 'WARNING, OVERWRITING EXISTING DIRECTORY'
        FileUtils.remove_dir(attempt_dir, true)
        FileUtils.mkdir_p(attempt_dir)
      end
      FileUtils.cp(
        Dir["usr/resources/#{language}/#{prompt.class_name}*.#{lang}"],
        attempt_dir)
      File.open(attempt_dir + '/' + prompt.class_name + '.' + lang, 'w') do |f|
        f.write(code_body)
      end

      # This "switch" based on language type needs to be refactored
      # to be more OO

      if language == "Java"
        result = execute_javatest(prompt.class_name, attempt_dir)
      elsif language == "Ruby"
        result = execute_rubytest(prompt.class_name, attempt_dir)
      elsif language == "Python"
        result = execute_pythontest(prompt.class_name, attempt_dir)
      end # IF INNERMOST

      correct = 0.0
      total = 0.0
      # print "RESULT",result,"RESULT"
      puts "FILE SIZE",
        File.size?(prompt.class_name + "_#{language}_results.csv").class
      puts "JAHAERYS", prompt.class_name + "_#{language}_results.csv"
      if File.size?(prompt.class_name + "_#{language}_results.csv").nil?
        feedback = result.split("#{prompt_question.class_name}Test")[2]
        puts "CODE-ERROR-FEEDBACK", "CODE-ERROR-FEEDBACK"
        prompt.test_cases.each_with_index do |tc,i|
          record_test_case_result(uid, 0.0, ex,
            "CODE-ERROR-CODE-ERROR " + feedback.to_s, i)
        end
        correct = 0.0
        total = 1.0
      else
        puts "ASSERTIONS-FEEDBACK","ASSERTIONS-FEEDBACK"
        CSV.foreach(prompt.class_name + "_#{language}_results.csv") do |line|
          weight = prompt.test_cases[line[2].to_i - 1].weight
          test_case_negative_feedback = prompt.
            test_cases[line[2].to_i - 1].negative_feedback
          correct += line[0].to_f * weight
          if line[0].to_f >= 1.0
            feedback = ''
          else
            if line[1]
              feedback = line[1]
            else
              feedback = 'Test case not completely passed'
            end
            if !test_case_negative_feedback.blank?
              feedback = feedback + ' ' + test_case_negative_feedback
            end
          end
          record_test_case_result(
            user_id,
            line[0].to_f,
            prompt,
            feedback,
            line[2].to_i - 1,
            attempt_id)
          total += weight
        end  # CSV end
      end
      record_attempt(exv, user_id, workout_id, correct, total, attempt_id)
      ActiveSupport::Notifications.instrument(
        "record_#{current_attempt}_attempt", extra: :nothing) do
        puts "SKYFALL","SKYFALL","SKYFALL","SKYFALL"
      end
    end
  end


  # private methods

  private

  def record_attempt(
    exv, user_id, workout_id, correct, total_weight, attempt_id)
    exworkout = ExerciseWorkout.find_by(
      exercise_id: exv.exercise.id, workout_id: workout_id)
    multiplier = exworkout ? exworkout.points : 1.0
    scr = correct * multiplier / total_weight
    attempt = Attempt.find(attempt_id)
    if exworkout
      attempt.workout_score =
        record_workout_score(user_id, scr, exv, exworkout.workout)
    end
    attempt.score = scr
    # TODO Make the experience earned dynamic
    attempt.experience_earned = 10

    attempt.save!
  end


  def record_test_case_result(
    user_id, score, prompt, feedback, index, attempt_id)
    test_case = prompt.test_cases[index]
    tcr = TestCaseResult.new(test_case: test_case, user_id: user_id)
    if score >= 1.0
      tcr.pass = true
    else
      tcr.pass = false
    end
    tcr.execution_feedback = feedback
    tcr.coding_prompt_answer =
      Attempt.find(attempt_id).prompt_answers.first.specific
    test_case.test_case_results << tcr
    tcr.save!
    tcr
  end


  def record_workout_score(user_id, score, exv, workout)
    scoring = WorkoutScore.find_by(user_id: user_id, workout: workout)

    # FIXME: This code repeats code in code_worker.rb and needs to be
    # refactored, probably as a method (or constructor?) in WorkoutScore.
    if !scoring
      scoring = WorkoutScore.new(
        user_id: user_id,
        workout: workout,
        score: score,
        last_attempted_at: Time.now,
        exercises_completed: 1,
        exercises_remaining: workout.exercises.length - 1)
      workout.workout_scores << scoring
      User.find(user_id).workout_scores << scoring
    else # At least one exercise has been attempted as a part of the workout
      scoring.score += score
      scoring.last_attempted_at = Time.now
      # FIXME: This is broken.  It will simply find the latest attempt,
      # which is the one being recorded(!), which is incorrect.  This needs
      # to be updated.
      user_exercise_score = nil
        # This query has to be rewritten anyway, since the workout id is
        # not stored in the attempt, and this query requires a join with
        # the workout score model:
        # Attempt.find_by(user_id: user_id,
        # exercise_version: exv, workout: workout).andand.score
      if user_exercise_score
        scoring.score -= user_exercise_score
      else
        scoring.exercises_completed += 1
        scoring.exercises_remaining -= 1
        # Compensate if overshoots
        if scoring.exercises_completed > workout.exercises.length
          scoring.exercises_completed = workout.exercises.length
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
    return scoring
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
