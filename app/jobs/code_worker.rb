# app/workers/code_worker.rb

require 'net/http'
require 'uri'
require 'csv'
require 'fileutils'
require "#{Rails.root}/usr/resources/config"

class CodeWorker
  include SuckerPunch::Job

  # Reducing to 2 workers, since it seems that each puma process will
  # have its own job queue and its own set of sucker punch worker threads.
  # We'll get parallelism through puma processes instead of sucker punch
  # workers.
  workers 2 # 10

  # -------------------------------------------------------------
  def perform(attempt_id)
    ActiveRecord::Base.connection_pool.with_connection do
      start_time = Time.now

      attempt = Attempt.find(attempt_id)
      exv = attempt.exercise_version
      prompt = exv.prompts.first.specific
      pre_lines = 0
      answer =
        attempt.prompt_answers.where(prompt: prompt.acting_as).first.specific
      answer_text = answer.answer
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

      # compile and evaluate the attempt in a temporary location 
      attempt_dir = "usr/attempts/active/#{current_attempt}"
      # puts "DIRECTORY",attempt_dir,"DIRECTORY"
      FileUtils.mkdir_p(attempt_dir)
      if !Dir[attempt_dir].empty?
        puts 'WARNING, OVERWRITING EXISTING DIRECTORY = ' + attempt_dir
        FileUtils.remove_dir(attempt_dir, true)
        FileUtils.mkdir_p(attempt_dir)
      end
      FileUtils.cp(prompt.test_file_name, attempt_dir)
      File.write(attempt_dir + '/' + prompt.class_name + '.' + lang, code_body)

      # Run static checks
      result = nil
      static_screening_failed = false
      prompt.test_cases.only_static.each do |test_case|
        this_result = test_case.apply_static_check(answer)
        if this_result
          if !static_screening_failed
            result = this_result
            static_screening_failed = true
            answer.error = result
          end
        end
      end

      if !static_screening_failed
        case language
        when 'Java'
          result = execute_javatest(
            prompt.class_name, attempt_dir, pre_lines, answer_lines)
        when 'Ruby'
          result = execute_rubytest(
            prompt.class_name, attempt_dir, pre_lines, answer_lines)
        when 'Python'
          result = execute_pythontest(
            prompt.class_name, attempt_dir, pre_lines, answer_lines)
        end
      end

      correct = 0.0
      total = 0.0
      if static_screening_failed || !File.exist?(attempt_dir + '/results.csv')
        answer.error = result
        total = 1.0
        answer.save
      else
        screening_failed = false
        CSV.foreach(attempt_dir + '/results.csv') do |line|
          # find test id
          test_id = line[2][/\d+$/].to_i
          test_case = prompt.test_cases.where(id: test_id).first
          tc_score = test_case.record_result(answer, line)
          if test_case.screening?
            tcr = TestCaseResult.find(attempt: attempt, test_case: test_case).first
            if !tcr.pass?
              screening_failed = true
              correct = 0.0
            end
          else
            if !screening_failed
              correct += tc_score
            end
            total += test_case.weight
          end
        end  # CSV end
      end
      #static analysis
      result_sa= execute_java_sa(answer, attempt_dir,answer_lines, answer_text, prompt.test_cases)
      multiplier = 1.0
      attempt.score = correct * multiplier / total
      attempt.experience_earned = attempt.score * exv.exercise.experience / attempt.submit_num
      attempt.feedback_ready = true

      # clean up log and class files that were generated during testing 
      cleanup_files = Dir.glob("#{attempt_dir}/*.class") + Dir.glob("#{attempt_dir}/*.log") +
        Dir.glob("#{attempt_dir}/reports/TEST-*.csv")
      cleanup_files.each do |file|
        File.delete(file)
      end

      # move the attempt to permanent storage
      term_dir = "usr/attempts/#{term_name}/"
      FileUtils.mkdir_p(term_dir) # create the term_dir if it doesn't exist
      FileUtils.mv(attempt_dir, term_dir)
      
      # calculate various time values. all times are in ms       
      time_taken = (Time.now - attempt.submit_time) * 1000

      updater = FeedbackTimeoutUpdater.instance 
      updater.update_timeout(time_taken)

      attempt.feedback_timeout = updater.avg_timeout
      attempt.time_taken = time_taken

      worker_time = (Time.now - start_time) * 1000
      attempt.worker_time = worker_time

      if attempt.workout_score
        attempt.score *= attempt.workout_score.workout.exercise_workouts.
          where(exercise: exv.exercise).first.points
        attempt.save!
        attempt.workout_score.record_attempt(attempt)
      else
        attempt.save!
      end
      
      Rails.logger.info "[pid:#{Process.pid}/thread:#{Thread.current.object_id}] " \
        "processed attempt #{attempt_id} in #{worker_time}ms"
      Rails.logger.info "[pid:#{Process.pid}/thread:#{Thread.current.object_id}] " \
        "time taken for attempt: #{attempt.time_taken} new feedback timeout: " \
        "#{attempt.feedback_timeout}"
    end
  end


  #~ Private instance methods .................................................
  private

  # -------------------------------------------------------------
  def execute_javatest(class_name, attempt_dir, pre_lines, answer_lines)
    if CodeWorkout::Config::JAVA.key? :daemon_url
      url = CodeWorkout::Config::JAVA[:daemon_url] % {attempt_dir: attempt_dir}
      response = Net::HTTP.get_response(URI.parse(url))
      puts "%{url} => response %{response.code}"
    else
      cmd = CodeWorkout::Config::JAVA[:ant_cmd] % {attempt_dir: attempt_dir}
      system(cmd + '>> err.log 2>> err.log')
    end

    # Parse compiler output for error messages to determine success
    error = ''
    logfile = attempt_dir + '/reports/compile.log'
    if File.exist?(logfile)
      xtra = ''
      skip = 0
      compile_out = File.foreach(logfile) do |line|
        line.chomp!
        # puts "checking line: #{line}"
        if line =~ /^\S+\.java:\s*([0-9]+)\s*:\s*(?:warning:\s*)?(.*)/
          line_no = $1.to_i - pre_lines
          if line_no > answer_lines
            line_no = answer_lines
            xtra = ', maybe a missing delimiter or closing brace?'
          end
          if !error.blank?
            error += '. '
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


  def execute_java_sa(answer, attempt_dir, answer_lines, answer_text, test_cases)
    total = 0
    correct = 0
    #remove comments from code
    answer_no_comments = answer_text.gsub(/\/\/[^\n]*|\/\*(?:[^*]|\*(?!\/))*\*\//,'')
    function_name = answer_no_comments[/ \w*\d*\s*\(/]
    function_name = function_name[/\w+\d*/]
    test_cases.where(description: 'static_analysis').each do |tc|
      case tc.expected_output
        when /recursive/
          #Count the number of times the function is called.
          recursive_call=Regexp.new function_name+"\\s*\\("
          #if the number of function calls is greater than 1, the solution is recursive
          use_recursion = answer_no_comments.scan(recursive_call).count>1
          if not use_recursion
            line = Array.new(8)
            line[6] = 'The solution is not recursive'
            line[7] = 0;
            correct += tc.record_result(answer, line)
            total += tc.weight
          end
        when /^No\s*/i
          answer_with_numbers = answer_text.lines.each_with_index{|line, index|
            line.insert(0, "[#{index+1}]")
          }.join('')
          answer_with_numbers.gsub!(/\/\/[^\n]*|\/\*(?:[^*]|\*(?!\/))*\*\//,'')
          not_allowed_text = tc.expected_output.sub(/No\s*/i,'')
          not_allowed = not_allowed_text.gsub(/ +|\t+/, '')
          lnum = Array.new
          answer_with_numbers.gsub(/ +|\t+/, '').lines.each{|line|
            lnum << (line.match(/\d+/)[0].to_i) if line.sub(/[\d]/,'')[not_allowed]
          }
          # not_allowed = Regexp.new not_allowed+"\\s*\\(" if tc.expected_output.include? '('
          if lnum.any?
            line = Array.new(8)
            if !tc.negative_feedback.blank?
              tc.negative_feedback << ' Lines: ' + lnum.join(", ")
            else
              line[6] = 'The use of "'+ not_allowed_text +'" is not allowed. Lines: ' + lnum.join(", ")
            end
            line[7] = 0
            correct += tc.record_result(answer, line)
            total += tc.weight
          end

        when /^Include\s*/i
          must_include = tc.expected_output.sub(/Include\s*/i,'')
          must_include.gsub!(/\s+/, '')
          # must_include = Regexp.new must_include+"\\s*\\(" if tc.expected_output.include? '('
          if answer_no_comments.gsub(/\s+/, '').scan(must_include).count == 0
            line = Array.new(8)
            line[6] = 'The use of "'+ must_include +'" is required'
            line[7] = 0;
            correct += tc.record_result(answer, line)
            total += tc.weight
          end
      end
    end
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
