require 'json'

require_relative 'job_buffer'
require_relative 'job_criteria_matcher'

class JobDetailReceiverService

  def initialize(plumbing_adapter, job_buffer)
    @plumbing_adapter=plumbing_adapter
    @plumbing_adapter.register_topic('job_data')
    @plumbing_adapter.register_topic('route')
    @plumbing_adapter.register_topic('heartbeat')
    @plumbing_adapter.register_topic('config')
    
    @job_buffer = job_buffer
  end
  
  def start
    @poll = true
    @heartbeat=Time.now 
    Thread.abort_on_exception=true
    @thread_main = Thread.new {
      begin 
        check_job_details
        check_config
        check_heartbeat
      end while @poll
   }  
  end
  
  def check_job_details
    job_message = @plumbing_adapter.get_message('job_data') 
      
    if job_message != '' 
      parsed_message = JSON.parse(job_message)
      @job_buffer.update_buffer(parsed_message)
      available_jobs = @job_buffer.available_jobs
        
      #look at complete jobs
      available_jobs.each do |job_id|
        puts "job '#{job_id}' is ready!"
        job_hash = @job_buffer.job(job_id)
        job_hash.store('job_id',job_id)
        puts "job:#{job_hash}"
        job_complete = job_hash.to_json
        puts job_complete.inspect
        @plumbing_adapter.send_message('route', job_complete)
        @job_buffer.remove_job(job_id)
      end
    end
  end
  
  def check_config
    config_message = @plumbing_adapter.get_message('config')
    if config_message != ''
      @plumbing_adapter.send_message('config', 'job_detail_receiver_config...')
    end
  end
  
  def check_heartbeat 
    if( (Time.now - @heartbeat) > 60) then
      @heartbeat = Time.now
      @plumbing_adapter.send_message('heartbeat', 'job_detail_receiver_heartbeat...')
    end
  end
   
  def stop
    @poll = false
    @thread_main.join
    @plumbing_adapter.close
  end
  
end