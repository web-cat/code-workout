class SseController < ApplicationController
  include ActionController::Live
  def feedback_send
    response.headers['Content-Type'] = 'text/event-stream'
     
    sse = SSE.new(response.stream, retry: 300, event: "feedback_#{params[:att_id]}") # Feedbacker::SSE.new(response.stream)    
    max_attempt = params[:att_id]
    puts "FINGON","record_#{max_attempt}_attempt","FINGON"    
    flag = true
    ActiveSupport::Notifications.subscribe("record_#{max_attempt}_attempt") do |*args|
      begin                          
        puts "WORKING","USER-#{current_user.id}","ATTEMPT-#{params[:att_id]}","WORKING"
        sse.write({arg: args})
                
      rescue IOError
          puts "IOError","IOError","IOError"
      ensure
          flag = false
          sse.close            
      end          
    end
    while flag
      sleep(1)
    end
    render nothing: true
  end
  
end
