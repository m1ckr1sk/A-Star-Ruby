class RabbitPlumbingAdapter
  def initialize(destination) 
    # Start a communication session with RabbitMQ
    @conn = Bunny.new(destination, :automatically_recover => false)
    @conn.start
    
    # open a channel
    @channel = @conn.create_channel
    
    #intialise the topics
    @topics = Hash.new
  end
  
  def register_topic(topic_name)
    @topics[topic_name] = @channel.queue(topic_name)
  end
  
  def send_message(topic_name, message)
    @topics[topic_name].publish(message)
  end
  
  def get_message(topic_name, blocking)
    message_body = ''
    @topics[topic_name].subscribe(:block => true) do |delivery_info, properties, body|
      message_body = body
      puts " [x] Received '#{message_body}'"
      # cancel the consumer to exit
      delivery_info.consumer.cancel
    end
    
    return message_body
  end
  
  def close
    puts "closing connection"
    @conn.stop
  end
end