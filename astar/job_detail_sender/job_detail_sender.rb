require "bunny"

require_relative '../configuration'

# Start a communication session with RabbitMQ
conn = Bunny.new(Configuration.rabbitmq_url, :automatically_recover => false)
conn.start

# open a channel
ch = conn.create_channel

# declare a queue
q  = ch.queue("job_data")

# publish a message to the default exchange which then gets routed to this queue
q.publish('{"message":"end_point", "job_id":"1","value":"x,9,y,9"}')
sleep(5)
q.publish('{"message":"start_point", "job_id":"1","value":"x,0,y,0"}')
sleep(5)
q.publish('{"message":"map", "job_id":"1","value":"0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n"}')

# close the connection
conn.stop