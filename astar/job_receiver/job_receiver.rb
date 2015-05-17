require_relative '../lib/configuration'
require_relative '../lib/rabbit_plumbing_adapter'
require_relative 'job_receiver_service'

rabbit_plumbing_adapter=RabbitPlumbingAdapter.new(Configuration.rabbitmq_url)
job_receiver_service=JobReceiverService.new(rabbit_plumbing_adapter)

begin
  puts " [*] Job receiver ------"
  puts " [*] Receiving processed messages..."
  puts " [*] To exit press CTRL+C"
  job_receiver_service.start
 
  begin
    sleep(10)
  end while true
  
rescue Interrupt => _
  job_receiver_service.stop

  exit(0)
end