require 'json'
require_relative '../job_detail_receiver/job_buffer'

describe 'job_buffer' do
  
it 'should return a job when all critieria for a complete job is met' do
  
  #Arrange
  job_id = 'test_job_1'
  job_criteria_matcher = CriteriaMatcher.new(["start_point","end_point","map"])
  job_buffer = JobBuffer.new(job_criteria_matcher)
  
  start_point_job_message = JSON.parse('{"message":"start_point", "job_id":"'+job_id+'","value":"x,0,y,0"}')
  job_buffer.update_buffer(start_point_job_message)
    
  end_point_job_message = JSON.parse('{"message":"end_point", "job_id":"'+job_id+'","value":"x,9,y,9"}')
  job_buffer.update_buffer(end_point_job_message)
    
  map_job_message = JSON.parse('{"message":"map", "job_id":"'+job_id+'","value":"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"}')
  job_buffer.update_buffer(map_job_message)
    
  #Act  
  available_jobs = job_buffer.available_jobs
  
  #Assert
  available_jobs.each do |job_id|
    puts "COMPLETE JOB: #{job_id}"
  end
  expect(available_jobs).to include(job_id)
  
end

it 'should not return a job when only partial critieria for a complete job is met' do
  
  #Arrange
  job_id = 'test_job_1'
  job_criteria_matcher = CriteriaMatcher.new(["start_point","end_point","map"])
  job_buffer = JobBuffer.new(job_criteria_matcher)
  
  start_point_job_message = JSON.parse('{"message":"start_point", "job_id":"'+job_id+'","value":"x,0,y,0"}')
  job_buffer.update_buffer(start_point_job_message)
    
  end_point_job_message = JSON.parse('{"message":"end_point", "job_id":"'+job_id+'","value":"x,9,y,9"}')
  job_buffer.update_buffer(end_point_job_message)
     
  #Act  
  available_jobs = job_buffer.available_jobs
  puts "jobs ready:#{available_jobs}"
  
  #Assert
  expect(available_jobs).not_to include(job_id)
  
end

it 'should remove a job from its buffer' do
  
  #Arrange
  job_id_1 = 'test_job_1'
  job_criteria_matcher = CriteriaMatcher.new(["start_point","end_point","map"])
  job_buffer = JobBuffer.new(job_criteria_matcher)
  
  start_point_job_message = JSON.parse('{"message":"start_point", "job_id":"'+job_id_1+'","value":"x,0,y,0"}')
  job_buffer.update_buffer(start_point_job_message)
    
  end_point_job_message = JSON.parse('{"message":"end_point", "job_id":"'+job_id_1+'","value":"x,9,y,9"}')
  job_buffer.update_buffer(end_point_job_message)
    
  map_job_message = JSON.parse('{"message":"map", "job_id":"'+job_id_1+'","value":"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"}')
  job_buffer.update_buffer(map_job_message)
  
  job_id_2 = 'test_job_2'
  job_criteria_matcher = CriteriaMatcher.new(["start_point","end_point","map"])
  
  start_point_job_message = JSON.parse('{"message":"start_point", "job_id":"'+job_id_2+'","value":"x,0,y,0"}')
  job_buffer.update_buffer(start_point_job_message)
    
  end_point_job_message = JSON.parse('{"message":"end_point", "job_id":"'+job_id_2+'","value":"x,9,y,9"}')
  job_buffer.update_buffer(end_point_job_message)
    
  map_job_message = JSON.parse('{"message":"map", "job_id":"'+job_id_2+'","value":"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"}')
  job_buffer.update_buffer(map_job_message)
    
  #Act  
  available_jobs = job_buffer.available_jobs
  
  #Assert
  puts "jobs ready:#{available_jobs}"
  
  expect(available_jobs).to include(job_id_1)
  expect(available_jobs).to include(job_id_2)
  
  job_buffer.remove_job(job_id_1)
  available_jobs = job_buffer.available_jobs
  puts "jobs ready:#{available_jobs}"
  
  expect(available_jobs).not_to include(job_id_1)
 
end
end


