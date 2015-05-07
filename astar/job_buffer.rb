class JobBuffer
	def initialize(job_criteria_matcher)
		@job_buffer = Hash.new{|hash, key| hash[key] = Hash.new{|hash, key| hash[key] = ""}}
		@job_criteria_matcher = job_criteria_matcher
	end

	def update_buffer(message)
		@job_buffer[message["job_id"]][message["message"]] = message["value"]
	end
	
	def remove_job(job_id)
		@job_buffer.delete job_id
	end
	
	def available_jobs
		available_jobs = []
	
		@job_buffer.each do |key, value|
		  start_available = false
		  end_available = false
		  map_available = false
		  
		  value.each do |k,v|
			if k == "start_point"
				start_available = true
			end
			
			if k == "end_point"
				end_available = true
			end
			
			if k == "map"
				map_available = true
			end
		  end
		  
		  if start_available && end_available && map_available then
			available_jobs << key
		  end 
		end
		
		return available_jobs
	end
	
end