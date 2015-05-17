# Require configuration
require_relative '../lib/configuration'
require_relative '../lib/rabbit_plumbing_adapter'
require_relative 'job_detail_receiver_service'
require_relative 'job_buffer'
require_relative 'job_criteria_matcher'

rabbit_plumbing_adapter=RabbitPlumbingAdapter.new(Configuration.rabbitmq_url)
job_criteria_matcher = JobCriteriaMatcher.new(["start_point","end_point","map"])
job_buffer = JobBuffer.new(job_criteria_matcher)
job_detail_receiver_service = JobDetailReceiverService.new(rabbit_plumbing_adapter,job_buffer)

begin
  puts " [*] Job detail receiver ------"
  puts " [*] Receiving processed messages..."
  puts " [*] To exit press CTRL+C"
  job_detail_receiver_service.start
  
  begin
    sleep(10)
  end while true
  
rescue Interrupt => _
  job_detail_receiver_service.stop
  exit(0)
end