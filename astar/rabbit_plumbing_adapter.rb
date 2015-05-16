require "bunny"

class RabbitPlumbingAdapter
  def initialize(destination) 
    # Start a communication session with RabbitMQ
    @conn = Bunny.new(destination, :automatically_recover => false)
    @conn.start
    
    # open a channel
    @channel = @conn.create_channel
    
    # intialise the topics
    @topics = Hash.new
  end
  
  def register_topic(topic_name)
    puts "[x] Registering #{topic_name}"
    @topics[topic_name] = @channel.queue(topic_name)
  end
  
  def send_message(topic_name, message)
    puts " [x] Sending '#{message}' to '#{topic_name}'"
    @topics[topic_name].publish(message)
  end
  
  def get_message(topic_name)
    delivery_info, properties, content = @topics[topic_name].pop
    message_body = if content
                    puts " [x] Received '#{content}'"
                    content
                    else
                      ""
                    end
    return message_body
  end
  
  def close
    puts " [x] Closing connection"
    @conn.stop
  end
end