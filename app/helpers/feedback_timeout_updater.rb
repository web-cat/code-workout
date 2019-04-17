require 'thread'
require 'singleton'

class FeedbackTimeoutUpdater
  include Singleton
  
  def initialize
    @semaphore = Mutex.new
    @avg_timeout = 2000 
  end
  attr_accessor :avg_timeout

  def update_timeout(time_taken)
    @semaphore.synchronize do 
      new_avg = ((9 * @avg_timeout) + time_taken) / 10
      Rails.application.config.feedback_timeout = new_avg > 2000 ? new_avg : 2000
      @avg_timeout = new_avg
    end
  end
end
