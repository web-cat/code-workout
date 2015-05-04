class SseController < ApplicationController
  include ActionController::Live
  def feedback_send
    response.headers['Content-Type'] = 'text/event-stream'
     
    sse = SSE.new(response.stream, retry: 300, event: "feedback_#{current_user.id}") # Feedbacker::SSE.new(response.stream)    
    max_attempt = params[:att_id]
    puts "FINGON","record_#{max_attempt}_attempt","FINGON"    
    flag = true
    ActiveSupport::Notifications.subscribe("record_#{max_attempt}_attempt") do |*args|
      begin                          
        puts "WORKING","TYENE","WORKING"
        sse.write({arg: args})
                
      rescue IOError
          puts "IOError","IOError","IOError"
      ensure
          flag = false
          sse.close
          puts "NOTHING","NOTHING","NOTHING"   
      end          
    end
    while flag
      sleep(1)
    end
    render nothing: true
  end
  
  def last_attempt
    response.headers['Content-Type'] = 'text/json'
    render json: Attempt.where(user: current_user)[-1].id
  end
  
end
