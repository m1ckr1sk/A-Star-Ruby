class JobBuffer
	def initialize(job_criteria_matcher)
		@job_buffer = Hash.new{|hash, key| hash[key] = Hash.new{|hash, key| hash[key] = ""}}
		@job_criteria_matcher = job_criteria_matcher
	end

	def update_buffer(message)
		@job_buffer[message["job_id"]][message["message"]] = message["value"]
	end
	
	def remove_job(job_id)
		@job_buffer.delete(job_id)
	end
	
	def available_jobs
		available_jobs = []
		@job_buffer.each do |job_id, value|
		  if @job_criteria_matcher.matches_job_criteria(value) then
        	available_jobs << job_id
		  end 
		end
		return available_jobs
	end
  
  def job(job_id)
    return @job_buffer[job_id]
  end
end