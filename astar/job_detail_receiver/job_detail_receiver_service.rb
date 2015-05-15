require 'bunny'
require 'json'

require_relative 'job_buffer'
require_relative 'job_criteria_matcher'

class JobDetailReceiverService

  def initialize(plumbing_adapter)
    @plumbing_adapter=plumbing_adapter
    @plumbing_adapter.register_topic('job_data')
    @plumbing_adapter.register_topic('route')
    @plumbing_adapter.register_topic('heartbeat')
    @plumbing_adapter.register_topic('config')
    
    job_criteria_matcher = JobCriteriaMatcher.new(["start_point","end_point","map"])
    @job_buffer = JobBuffer.new(job_criteria_matcher)
  end
  
  def start
    @poll = true
    @heartbeat=Time.now 
    begin 

      job_message = @plumbing_adapter.get_message('job_data') 
      
      if job_message != '' 
        parsed_message = JSON.parse(job_message)
        @job_buffer.update_buffer(parsed_message)
        available_jobs = @job_buffer.available_jobs
        
        #look at complete jobs
        available_jobs.each do |job_id|
          puts "job '#{job_id}' is ready!"
          job_complete = @job_buffer.job(job_id).to_json
          @plumbing_adapter.send_message('route', job_complete)
        end
      end
      
      config_message = @plumbing_adapter.get_message('config')
      if config_message != ''
        @plumbing_adapter.send_message('config', 'job_detail_receiver_config...')
      end
      
    end while @poll
  end
   
  def stop
    @poll = false
    @plumbing_adapter.close
  end
  
end