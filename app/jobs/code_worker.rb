# app/workers/code_worker.rb
require 'csv'
require 'fileutils'
require "#{Rails.root}/usr/resources/config"

class CodeWorker
  include SuckerPunch::Job
  workers 20

  # -------------------------------------------------------------
  def perform(exercise_version_id, user_id, workout_id, attempt)
    ActiveRecord::Base.connection_pool.with_connection do
      exv = ExerciseVersion.find(exercise_version_id)
      prompt = exv.prompts.first.specific
      pre_lines = 0
      if !prompt.wrapper_code.blank?
        code_body = prompt.wrapper_code.sub(/\b___\b/,
          attempt.prompt_answers.first.specific.answer)
        if $`
          # Want pre_lines to be a count of the number of lines preceding
          # the one the match is on, so use count() instead of lines() here
          pre_lines = $`.count("\n")
        else
          puts 'ERROR: no answer insertion marker in wrapper code: ' +
            prompt.wrapper_code.to_s
        end
      end
      current_attempt = attempt.id.to_s
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
      #FileUtils.cp(
      #  Dir["usr/resources/#{language}/#{prompt.class_name}*.#{lang}"],
      #  attempt_dir)
      FileUtils.cp(prompt.test_file_name, attempt_dir)
      File.write(attempt_dir + '/' + prompt.class_name + '.' + lang, code_body)

      # This "switch" based on language type needs to be refactored
      # to be more OO

      if language == "Java"
        result = execute_javatest(prompt.class_name, attempt_dir, pre_lines)
      elsif language == "Ruby"
        result = execute_rubytest(prompt.class_name, attempt_dir, pre_lines)
      elsif language == "Python"
        result = execute_pythontest(prompt.class_name, attempt_dir, pre_lines)
      end # IF INNERMOST

      correct = 0.0
      total = 0.0
      # print "RESULT",result,"RESULT"
      puts 'FILE SIZE',
        File.size?(attempt_dir + '/results.csv').class
      puts "JAHAERYS", attempt_dir + '/results.csv'
      correct = 0.0
      total = 0.0
      answer =
        attempt.prompt_answers.where(prompt: prompt.acting_as).first.specific
      if !File.exist?(attempt_dir + '/results.csv')
        answer.error = result
        puts "CODE-ERROR-FEEDBACK", answer.error, "CODE-ERROR-FEEDBACK"
        total = 1.0
        answer.save
      else
        puts "ASSERTIONS-FEEDBACK","ASSERTIONS-FEEDBACK"
        CSV.foreach(attempt_dir + '/results.csv') do |line|
          # find test id
          test_name = line[2]
          p "test name = #{test_name}"
          test_id = test_name[/\d+/].to_i
          p "test id = #{test_id}"
          test_case = prompt.test_cases.where(id: test_id).first
          correct += test_case.record_result(answer, line)
          total += test_case.weight
        end  # CSV end
      end
      multiplier = 1.0
      if Workout.find_by(id: workout_id)
        WorkoutScore.record_workout_score(
          correct / total, exv.exercise, workout_id, User.find(user_id))
        multiplier  = ExerciseWorkout.find_by(
          exercise: exv.exercise,workout_id: workout_id).points
        attempt.workout_score = WorkoutScore.find_by(
          user_id: user_id, workout_id: workout_id)
      end
      attempt.score = correct * multiplier / total
      attempt.save!
      ActiveSupport::Notifications.instrument(
        "record_#{current_attempt}_attempt", extra: :nothing) do
        puts "SKYFALL","SKYFALL","SKYFALL","SKYFALL"
      end
    end
  end


  #~ Private instance methods .................................................
  private

  # -------------------------------------------------------------
  def execute_javatest(class_name, attempt_dir, pre_lines)
    cmd = CodeWorkout::Config::JAVA[:ant_cmd] % {attempt_dir: attempt_dir}
    if system(cmd +
      ">> #{attempt_dir}/err.log " +
      "2>> #{attempt_dir}/err.log")
      return nil
    else
      error = ''
      compile_out = File.foreach(attempt_dir + '/reports/compile.log') do |line|
        line.chomp!
        puts "checking line: #{line}"
        m = /^\s*\[javac\]\s/.match(line)
        if m
          line = m.post_match
        else
          break
        end
        puts "javac output: #{line}"
        if line =~ /^Compiling/
          next
        elsif line =~ /^\S+\.java:\s*([0-9]+)\s*:\s*(.*)/
          error += "line #{$1.to_i - pre_lines}: #{$2}"
          puts "error now: #{error}"
        elsif line =~ /^(found|expected|required|symbol)\s*:(.*)/
          error += "\n#{$1}: #{$2}"
          puts "error now: #{error}"
        else
          break
        end
      end
      if error.blank?
        error = nil
      end
      return error
    end
  end


  # -------------------------------------------------------------
  def execute_rubytest(class_name, attempt_dir, pre_lines)
    if system("ruby #{class_name}Test.rb",
      [:out, :err] => 'err.log',
      chdir: attempt_dir)
      puts 'FINE', 'RUBY FINE'
      return nil
    else
      puts 'ERROR', 'RUBY ERROR'
      return File.read(attempt_dir + '/err.log')
    end
  end


  # -------------------------------------------------------------
  def execute_pythontest(class_name, attempt_dir, pre_lines)
    if system("python #{class_name}Test.py",
      [:out, :err] => 'err.log',
      chdir: attempt_dir)
      return nil
    else
      return File.read(attempt_dir + '/err.log')
    end
  end

end
