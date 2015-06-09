require_relative '../route_receiver/route_receiver_service'

describe 'route_receiver_service_spec' do

it 'should register with the relevant topics' do
  
  #Arrange
  plumbing_adapter_spy=instance_spy("PlumbingAdapter")
  route_buffer_spy=instance_spy("RouteBuffer")
  
  #Act  
  @route_receiver_service = RouteReceiverService.new(plumbing_adapter_spy, route_buffer_spy)
  
  #Assert
  expect(plumbing_adapter_spy).to have_received(:register_topic).with('config')
  expect(plumbing_adapter_spy).to have_received(:register_topic).with('routed')
  expect(plumbing_adapter_spy).to have_received(:register_topic).with('heartbeat')
  
end

end


