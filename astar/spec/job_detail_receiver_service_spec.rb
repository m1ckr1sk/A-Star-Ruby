require_relative '../plumbing_adapter'
require_relative '../job_detail_receiver/job_detail_receiver_service'

describe 'job_detail_receiver_service_spec' do

it 'should register with the relevant topics' do
  
  #Arrange
  plumbing_adapter_spy=instance_spy("PlumbingAdapter")
  job_buffer_spy=instance_spy("JobBuffer")
  
  #Act  
  @job_detail_receiver_service = JobDetailReceiverService.new(plumbing_adapter_spy, job_buffer_spy)
  
  #Assert
  expect(plumbing_adapter_spy).to have_received(:register_topic).with('job_data')
  expect(plumbing_adapter_spy).to have_received(:register_topic).with('config')
  expect(plumbing_adapter_spy).to have_received(:register_topic).with('route')
  expect(plumbing_adapter_spy).to have_received(:register_topic).with('heartbeat')
  
end

end


