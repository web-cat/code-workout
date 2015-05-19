# app/workers/code_worker.rb
require 'csv'
require 'fileutils'
require "#{Rails.root}/usr/resources/config"

class CodeWorker
  include SuckerPunch::Job
  workers 20

  # -------------------------------------------------------------
  def perform(exercise_version_id, user_id, workout_id, attempt_id)
    ActiveRecord::Base.connection_pool.with_connection do
      exv = ExerciseVersion.find(exercise_version_id)
      prompt = exv.prompts.first.specific
      attempt = Attempt.find(attempt_id)
      if !prompt.wrapper_code.blank?
        code_body = prompt.wrapper_code.sub(/\b___\b/,
          attempt.prompt_answers.first.specific.answer)
      end
      current_attempt = attempt_id.to_s
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
        result = execute_javatest(prompt.class_name, attempt_dir)
      elsif language == "Ruby"
        result = execute_rubytest(prompt.class_name, attempt_dir)
      elsif language == "Python"
        result = execute_pythontest(prompt.class_name, attempt_dir)
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
        feedback = result.split("#{prompt.class_name}Test")[2]
        puts "CODE-ERROR-FEEDBACK", "CODE-ERROR-FEEDBACK"
        prompt.test_cases.each_with_index do |tc|
          test_case.record_result(answer, ['', '', '', '', '', '',
            'CODE-ERROR-CODE-ERROR ' + feedback, 0])
        end
        total = 1.0
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
      attempt.update_score(correct / total)
      ActiveSupport::Notifications.instrument(
        "record_#{current_attempt}_attempt", extra: :nothing) do
        puts "SKYFALL","SKYFALL","SKYFALL","SKYFALL"
      end
    end
  end


  #~ Private instance methods .................................................
  private

  # -------------------------------------------------------------
  def execute_javatest(class_name, attempt_dir)
    cmd = CodeWorkout::Config::JAVA[:ant_cmd] % {attempt_dir: attempt_dir}
    if system(cmd +
      ">> #{attempt_dir}/err.log " +
      "2>> #{attempt_dir}/err.log")
      return nil
    else
      return File.read(attempt_dir + '/compile.log')
    end
  end


  # -------------------------------------------------------------
  def execute_rubytest(class_name, attempt_dir)
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
  def execute_pythontest(class_name, attempt_dir)
    if system("python #{class_name}Test.py",
      [:out, :err] => 'err.log',
      chdir: attempt_dir)
      return nil
    else
      return File.read(attempt_dir + '/err.log')
    end
  end

end
