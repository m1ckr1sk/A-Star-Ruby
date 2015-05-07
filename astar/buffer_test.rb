require 'json'
require_relative 'job_buffer'
require_relative 'job_criteria_matcher'

job_criteria_matcher = JobCriteriaMatcher.new(["start_point","end_point","map"])
job_buffer = JobBuffer.new(job_criteria_matcher)

start_point_job_message = JSON.parse('{"message":"start_point", "job_id":"1","value":"x,0,y,0"}')
job_buffer.update_buffer(start_point_job_message)
puts "jobs ready:#{job_buffer.available_jobs}"

end_point_job_message = JSON.parse('{"message":"end_point", "job_id":"1","value":"x,9,y,9"}')
job_buffer.update_buffer(end_point_job_message)
puts "jobs ready:#{job_buffer.available_jobs}"

map_job_message = JSON.parse('{"message":"map", "job_id":"1","value":"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"}')
job_buffer.update_buffer(map_job_message)
puts "jobs ready:#{job_buffer.available_jobs}"

available_jobs = job_buffer.available_jobs
available_jobs.each do |job_id|
  puts "COMPLETE JOB: #{job_buffer.job(job_id)}"
  job_buffer.remove_job(job_id)
end
puts "jobs ready:#{job_buffer.available_jobs}"


