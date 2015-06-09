require_relative '../lib/criteria_matcher'

class RouteBuffer
	def initialize(route_criteria_matcher)
		@route_buffer = Hash.new{|hash, key| hash[key] = Hash.new{|hash, key| hash[key] = ""}}
		@route_criteria_matcher = route_criteria_matcher
	end

	def update_buffer(message)
		@route_buffer[message["job_id"]][message["message"]] = message["value"]
	end
	
	def remove_route(job_id)
		@route_buffer.delete(job_id)
	end
	
	def available_routes
		available_routes = []
		@route_buffer.each do |job_id, value|
		  if @route_criteria_matcher.matches_criteria(value) then
        	available_routes << job_id
		  end 
		end
		return available_routes
	end
  
	def route(job_id)
    	return @route_buffer[job_id]
  	end
end