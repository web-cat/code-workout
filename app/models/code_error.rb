class CodeError

# Class variables
@@WARNING   = 0
@@SYNTAX    = 1
@@RUNTIME   = 2
@@EXCEPTION = 3
@@TIMEOUT   = 4
@@FAILURE   = 5

# constants....
TYPES = {
    'warning' => @@WARNING,
    'syntax' => @@SYNTAX,
    'runtime' => @@RUNTIME,
    'exception' => @@EXCEPTION,
    'timeout' => @@TIMEOUT,
    'failure' => @@FAILURE,
    'other' => 6
}

# Methods....
  def initialize(type, line, msg, stack)
    @error_type = TYPES.key(type) || Types['other']
    @line = line
    @message = msg
    @stack_trace = stack
  end

  def summary
    readable = TYPES.key(@error_type) || ''
    return "#{readable}. #{message}"
  end

end