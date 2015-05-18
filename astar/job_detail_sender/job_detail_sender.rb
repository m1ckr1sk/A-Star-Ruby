# Require configuration
require_relative '../lib/configuration'
require_relative '../lib/rabbit_plumbing_adapter'
require_relative 'auto_job_detail_sender'

rabbit_plumbing_adapter=RabbitPlumbingAdapter.new(Configuration.rabbitmq_url)
auto_job_detail_sender=AutoJobDetailSender.new(rabbit_plumbing_adapter)
auto_job_detail_sender.send_job
auto_job_detail_sender.send_blocked_job

