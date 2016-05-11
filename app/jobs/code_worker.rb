# app/workers/code_worker.rb
require 'csv'
require 'fileutils'
require "#{Rails.root}/usr/resources/config"

class CodeWorker
  include SuckerPunch::Job
  workers 10

  # -------------------------------------------------------------
  def perform(attempt_id)
    ActiveRecord::Base.connection_pool.with_connection do
      attempt = Attempt.find(attempt_id)
      exv = attempt.exercise_version
      prompt = exv.prompts.first.specific
      pre_lines = 0
      answer_text = attempt.prompt_answers.first.specific.answer
      answer_lines = answer_text ? answer_text.count("\n") : 0
      if !prompt.wrapper_code.blank?
        code_body = prompt.wrapper_code.sub(/\b___\b/, answer_text)
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

      # puts "CodeWorker current working directory is #{Dir.pwd}"

      term = Term.current_term
      term_name = term ? term.slug : 'no-term'
      attempt_dir = 'usr/attempts/' + term_name + '/' + current_attempt
      # puts "DIRECTORY",attempt_dir,"DIRECTORY"
      FileUtils.mkdir_p(attempt_dir)
      if !Dir[attempt_dir].empty?
        puts 'WARNING, OVERWRITING EXISTING DIRECTORY = ' + attempt_dir
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
        result = execute_javatest(
          prompt.class_name, attempt_dir, pre_lines, answer_lines)
      elsif language == "Ruby"
        result = execute_rubytest(
          prompt.class_name, attempt_dir, pre_lines, answer_lines)
      elsif language == "Python"
        result = execute_pythontest(
          prompt.class_name, attempt_dir, pre_lines, answer_lines)
      end # IF INNERMOST

      correct = 0.0
      total = 0.0
      correct = 0.0
      total = 0.0
      answer =
        attempt.prompt_answers.where(prompt: prompt.acting_as).first.specific
      if !File.exist?(attempt_dir + '/results.csv')
        answer.error = result
        # puts "CODE-ERROR-FEEDBACK", answer.error, "CODE-ERROR-FEEDBACK"
        total = 1.0
        answer.save
      else
        CSV.foreach(attempt_dir + '/results.csv') do |line|
          # find test id
          test_id = line[2][/\d+/].to_i
          test_case = prompt.test_cases.where(id: test_id).first
          correct += test_case.record_result(answer, line)
          total += test_case.weight
        end  # CSV end
      end
      multiplier = 1.0
      attempt.score = correct * multiplier / total
      attempt.experience_earned = attempt.score * exv.exercise.experience / attempt.submit_num
      attempt.feedback_ready = true
      if attempt.workout_score
        attempt.score *= attempt.workout_score.workout.exercise_workouts.
          where(exercise: exv.exercise).first.points
        attempt.save!
        attempt.workout_score.record_attempt(attempt)
      else
        attempt.save!
      end

#      ActiveSupport::Notifications.instrument(
#        "record_#{current_attempt}_attempt", extra: :nothing) do
#        puts "SKYFALL"
#      end
    end
  end


  #~ Private instance methods .................................................
  private

  # -------------------------------------------------------------
  def execute_javatest(class_name, attempt_dir, pre_lines, answer_lines)
    cmd = CodeWorkout::Config::JAVA[:ant_cmd] % {attempt_dir: attempt_dir}
    system(cmd +
      ">> #{attempt_dir}/err.log " +
      "2>> #{attempt_dir}/err.log")

    # Parse compiler output for error messages to determine success
    error = ''
    logfile = attempt_dir + '/reports/compile.log'
    if File.exist?(logfile)
      xtra = ''
      skip = 0
      compile_out = File.foreach(logfile) do |line|
        line.chomp!
        # puts "checking line: #{line}"
        m = /^\s*\[javac\]\s/.match(line)
        if m
          line = m.post_match
        else
          break
        end
        # puts "javac output: #{line}"
        if line =~ /^Compiling/
          next
        elsif line =~ /^\S+\.java:\s*([0-9]+)\s*:\s*(?:warning:\s*)?(.*)/
          line_no = $1.to_i - pre_lines
          if line_no > answer_lines
            line_no = answer_lines
            xtra = ', maybe a missing delimiter or closing brace?'
          end
          error += "line #{line_no}: #{$2}#{xtra}"
          # puts "error now: #{error}"
          if !xtra.empty?
            break
          end
          skip = 2
        elsif line =~ /^\s*(found|expected|required|symbol)\s*:\s*(.*)/
          if $1 == 'symbol'
            error += ": #{$2}"
          else
            error += "\n#{$1}: #{$2}"
          end
          # puts "error now: #{error}"
          break
        else
          if skip == 0
            break
          else
            skip = skip - 1
          end
        end
      end
    end
    if error.blank?
      error = nil
    else
      # If there's an error, remove the test results, if any.
      # This causes warnings to be treated the same as errors.
      result_file = attempt_dir + '/results.csv'
      if File.exist?(result_file)
        File.delete(result_file)
      end
    end
    return error
  end


  # -------------------------------------------------------------
  def execute_rubytest(class_name, attempt_dir, pre_lines, answer_lines)
    return 'Ruby execution is temporarily suspended.'
#    if system("ruby #{class_name}Test.rb",
#      [:out, :err] => 'err.log',
#      chdir: attempt_dir)
#      puts 'FINE', 'RUBY FINE'
#      return nil
#    else
#      puts 'ERROR', 'RUBY ERROR'
#      return File.read(attempt_dir + '/err.log')
#    end
  end


  # -------------------------------------------------------------
  def execute_pythontest(class_name, attempt_dir, pre_lines, answer_lines)
    return 'Python execution is temporarily suspended.'
#    if system("python #{class_name}Test.py",
#      [:out, :err] => 'err.log',
#      chdir: attempt_dir)
#      return nil
#    else
#      return File.read(attempt_dir + '/err.log')
#    end
  end

end
