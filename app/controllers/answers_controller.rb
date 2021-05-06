class AnswersController < ApplicationController
  respond_to :json, :html
  def create
    
    if @exercise.nil? && @answer.nil?
      @exercise = Popexercise.find(params[:pop_exercise_id])
      @answer = @exercise.answers.create(answer_params)
      student_answer = params[:answer][:StudentCode]
    @answer = Answer.find_by_StudentCode(student_answer)
    if @answer.nil?
      #puts"new one created"
      @answer = @exercise.answers.create(StudentCode: student_answer)
    end
    if @answer.trace.nil?
      #puts"new trace created"
      trace = generate_code_trace(@exercise.code, student_answer)
      @trace = @answer.create_trace(exercise_trace: trace)
    else
      #puts"old trace used"
        @trace = @answer.trace
    end
    end

    redirect_to pop_exercise_path(@exercise)
  end

  def destroy
    @exercise = Popexercise.find(params[:pop_exercise_id])
    @answer = @exercise.answers.find(params[:id])
    @answer.trace.destroy unless @answer.trace.nil?
    @answer.destroy
    redirect_to pop_exercise_path(@exercise)
  end

  def visualize
    # puts params.inspect
    @exercise = Popexercise.find(params[:exercise_id])

    @answer = @exercise.answers.find(params[:id])
    # puts @answer.trace
    if @answer.trace.nil?
      # puts"new trace created"
      # puts @answer.trace
      trace = generate_code_trace(@exercise.code, @answer.StudentCode)
      @trace = @answer.create_trace(exercise_trace: trace)
    else
      #  puts"old trace used"
      @trace = @answer.trace
    end
    # puts @trace.exercise_trace
    @openpop_results = build_visualization(@trace.exercise_trace,
                                           @answer.StudentCode)
  end

  def solve
    @exercise = Popexercise.find_by_exercise_id(params[:exercise_id])
    student_answer = params[:code]
    student_answer = student_answer[student_answer.index('{')+1..student_answer.index('return')-1]
    @answer = Answer.find_by_StudentCode(student_answer)
    if @answer.nil?
      #puts"new one created"
      @answer = @exercise.answers.create(StudentCode: student_answer)
    end
    if @answer.trace.nil?
      #puts"new trace created"
      trace = generate_code_trace(@exercise.code, student_answer)
      @trace = @answer.create_trace(exercise_trace: trace)
    else
      #puts"old trace used"
        @trace = @answer.trace
    end
    #puts @trace.exercise_trace
    #results = JSON.parse('[' + trace + ']')
    #respond_with json: trace
    respond_to do |format|
      format.json { render :json => @trace }  # note, no :location or :status options
    end
  end

  def oldsolve
    id = params[:exerciseByID]
    solution = params[:solution]
    @exercise = Exercise.find_by_exercise_id(id)
    @answer = Answer.create(StudentCode: solution)
    #puts @exercise.code
    @answer = @exercise.answers.create(StudentCode: solution)
    redirect_to "/answers/visualize/exercises/#{@exercise.id}/answers/#{@answer.id}"
  end

  private
  def answer_params
    params.require(:answer).permit(:StudentCode)
  end

  def generate_code_trace(exercise, code)
    wrapper_code = exercise# @exercise.code
    answer_text = code # @answer.StudentCode
    path = File.join(File.dirname(File.expand_path('../..', __FILE__)), 'Java-Visualizer')
    Dir.chdir path
    require path + '/' + 'RubyJsonFilter.rb'
    code_body = wrapper_code.sub(/\b__\b/, answer_text)
    code_body.gsub! "\r",''
    code_body.gsub! '\r',''
    code_trace = main_path('',code_body)
    #remove the last comma
    #trace = ""
    #(0...code_trace.length).each do |y|
    #  if y == code_trace.length - 1
    #    temp_string = code_trace[y]
    #    temp_string = temp_string[0...-1]
    #    trace = trace + temp_string
    #  else
    #    temp_string = code_trace[y]
    #    trace = trace + temp_string + "\n"
    #  end
    #end
    #results = "<script>" + codeTrace.split('$')[0] + "</script>"
    ##@openpop_results = "<script>" + create_student_full_code('{p=r;\n return 0;}').split('$')[0] + "</script>"
    #results.sub!('$', '</script><script> $')
    #@openpop_results = results
    #Dir.chdir pwd
    #return trace
    code_trace
  end

  def build_visualization(trace, student_code)
    newStudentCode = student_code.split(/\n/).join('\\n')
    first = 'var testvisualizerTrace = {"code":"' + newStudentCode + '"'
    second = ',"trace":[' + trace
    last = ']}'
    body = '<body onload="visualize(testvisualizerTrace);"/>'
    '<script>' + first + second + last + '</script>' + body
  end
end
