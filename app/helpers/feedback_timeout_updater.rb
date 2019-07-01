require 'thread'
require 'singleton'

class FeedbackTimeoutUpdater
  include Singleton
  
  # constants in milliseconds 
  MIN_THRESHOLD = 1700 # minus the 300 padding
  MAX_THRESHOLD = 7700

  def initialize
    @semaphore = Mutex.new
    @avg_timeout = 1700 
  end
  attr_accessor :avg_timeout

  # Update the feedback_timeout config value based on
  # the given value. The argument is assumed to be in
  # milliseconds.
  def update_timeout(time_taken)
    @semaphore.synchronize do 
      new_avg = (
        ((9 * @avg_timeout) + time_taken) / 10
      )
      Rails.application.config.feedback_timeout =
        new_avg > MIN_THRESHOLD ?
        (
          new_avg < MAX_THRESHOLD ? 
          new_avg :
          MAX_THRESHOLD
        ) :
        MIN_THRESHOLD
      @avg_timeout = new_avg
    end
  end
end

