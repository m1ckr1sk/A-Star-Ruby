require_relative '../lib/configuration'
require_relative '../lib/rabbit_plumbing_adapter'
require_relative 'route_receiver_service'
require_relative 'route_buffer'

route_criteria_matcher = CriteriaMatcher.new(['map','route'])
route_buffer = RouteBuffer.new(route_criteria_matcher)
rabbit_plumbing_adapter=RabbitPlumbingAdapter.new(Configuration.rabbitmq_url)
route_receiver_service=RouteReceiverService.new(rabbit_plumbing_adapter,route_buffer)

begin
  puts " [*] Route receiver ------"
  puts " [*] Receiving processed messages..."
  puts " [*] To exit press CTRL+C"
  route_receiver_service.start
 
  begin
    sleep(10)
  end while true
  
rescue Interrupt => _
  route_receiver_service.stop

  exit(0)
end
