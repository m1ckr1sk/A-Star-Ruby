require 'bunny'
require 'json'

# Require configuration
require_relative '../configuration'
require_relative 'job_buffer'
require_relative 'job_criteria_matcher'

def send_message(data, queue)
  send_conn = Bunny.new(Configuration.rabbitmq_url, :automatically_recover => false)
  send_conn.start
  send_ch = send_conn.create_channel
  send_q = send_ch.queue(queue)
  send_ch.default_exchange.publish(data, :routing_key => send_q.name, :persistent => true)
  puts " [x] Processed '#{data}'"
  send_conn.close
end

conn = Bunny.new(Configuration.rabbitmq_url, automatically_recover: false)
conn.start

ch   = conn.create_channel
q    = ch.queue("job_data")

job_criteria_matcher = JobCriteriaMatcher.new(["start_point","end_point","map"])
job_buffer = JobBuffer.new(job_criteria_matcher)

begin
  puts " [*] Job receiver ------"
  puts " [*] Receiving processed messages..."
  puts " [*] To exit press CTRL+C"
  q.subscribe(:block => true) do |delivery_info, properties, body|
    puts " [x] Received '#{body}'"
    
    parsed_message = JSON.parse(body)
    job_buffer.update_buffer(parsed_message)
    available_jobs = job_buffer.available_jobs
    available_jobs.each do |job_id|
      puts "job '#{job_id}' is ready!"
      job_complete = job_buffer.job(job_id).to_json
      puts "sending #{job_complete}"
      send_message(job_complete,"route")
    end
  end
rescue Interrupt => _
  conn.close

  exit(0)
end