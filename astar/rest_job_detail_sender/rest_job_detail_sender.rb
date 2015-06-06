require 'sinatra'
require 'json'
require 'bunny'
require_relative '../lib/configuration'
require_relative '../lib/rabbit_plumbing_adapter'

plumbing_adapter=RabbitPlumbingAdapter.new(Configuration.rabbitmq_url)
plumbing_adapter.register_topic('job_data')

# required to work in docker - comment it to run ouside docker
set :bind, '0.0.0.0'

post '/message' do
  request.body.rewind
  json = request.body.read
  puts '######################################################'
  puts json
  puts '######################################################'  
  plumbing_adapter.send_message('job_data',json)
end

get '/' do
  return "rest_job_detail_sender up\n"
end