require 'json'

class RouteReceiverService

def initialize(plumbing_adapter)
    @plumbing_adapter=plumbing_adapter
    @plumbing_adapter.register_topic('routed')
    @plumbing_adapter.register_topic('heartbeat')
    @plumbing_adapter.register_topic('config')
  end
  
  def start
    @poll = true
    @heartbeat=Time.now 
    Thread.abort_on_exception=true
    @thread_main = Thread.new {
      begin 
        check_routes
        check_config
        check_heartbeat
      end while @poll
   }  
  end
  
   def check_routes
    job_message = @plumbing_adapter.get_message('routed') 
    if job_message != '' 
      puts job_message
      parsed_message = JSON.parse(job_message)
      puts parsed_message.inspect
      draw_route(parsed_message.keys[0], parsed_message[parsed_message.keys[0]].split("\n"))
    end
  end
  
  def draw_route(job_id, lines)
      
    text = File.read(File.dirname(__FILE__) + '/route_template.html')
    replacement_string = ''
    lines.each do |line|
      xval = line.split(',')[1]
      yval = line.split(',')[3]
      replacement_string+="[#{xval},#{yval}],"
    end
    
    replacement_string = replacement_string[0...-1]
    new_contents = text.gsub(/@@@LINE_ARRAY@@@/, replacement_string)
    route_file_name=Time.now.strftime("%H_%M_%S")
    
    route_output_file="#{job_id}_#{route_file_name}.html"
    File.open(route_output_file, 'w') do |file| 
        file.puts(new_contents)
    end
    puts "Written route to #{route_output_file}"
  end
  
  def check_config
    config_message = @plumbing_adapter.get_message('config')
    if config_message != ''
      @plumbing_adapter.send_message('config', 'route_receiver_config...')
    end
  end
  
  def check_heartbeat 
    if( (Time.now - @heartbeat) > 60) then
      @heartbeat = Time.now
      @plumbing_adapter.send_message('heartbeat', 'route_receiver_heartbeat...')
    end
  end
   
  def stop
    @poll = false
    @thread_main.join
    @plumbing_adapter.close
  end
end