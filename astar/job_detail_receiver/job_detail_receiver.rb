# Require configuration
require_relative '../configuration'
require_relative '../rabbit_plumbing_adapter'
require_relative 'job_detail_receiver_service'

rabbit_plumbing_adapter=RabbitPlumbingAdapter.new(Configuration.rabbitmq_url)
job_detail_receiver_service = JobDetailReceiverService.new(rabbit_plumbing_adapter)
begin
  puts " [*] Job receiver ------"
  puts " [*] Receiving processed messages..."
  puts " [*] To exit press CTRL+C"
  job_detail_receiver_service.start
  
rescue Interrupt => _
  job_detail_receiver_service.stop
  exit(0)
end