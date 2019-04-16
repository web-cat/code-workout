require 'thread'
require 'singleton'

class FeedbackTimeoutUpdater
  include Singleton
  
  def initialize
    @semaphore = Mutex.new
    @avg_timeout = 2
  end
  attr_accessor :avg_timeout

  # time_taken in milliseconds
  def update_timeout(time_taken)
    @semaphore.synchronize { 
      new_avg = ((9 * @avg_timeout) + time_taken) / 10
      Rails.application.config.feedback_timeout = new_avg
      @avg_timeout = new_avg
    }
  end
end
