require 'json'
require_relative 'route_buffer'

class RouteReceiverService

  def initialize(plumbing_adapter, route_buffer)
    @plumbing_adapter=plumbing_adapter
    @plumbing_adapter.register_topic('job_data')
    @plumbing_adapter.register_topic('routed')
    @plumbing_adapter.register_topic('heartbeat')
    @plumbing_adapter.register_topic('config')
    @route_buffer = route_buffer
  end
  
  def start
    @poll = true
    @heartbeat=Time.now 
    Thread.abort_on_exception=true
    @thread_main = Thread.new {
      begin 
        check_maps
        check_routes
        check_config
        check_heartbeat
      end while @poll
   }  
  end
  
  def check_maps
    job_message = @plumbing_adapter.get_message('job_data') 
      
    if job_message != '' 
      parsed_message = JSON.parse(job_message)
      if parsed_message['message'] == 'map'
        @route_buffer.update_buffer(parsed_message)
      end
    end
  end
  
   def check_routes
    job_message = @plumbing_adapter.get_message('routed') 
    if job_message != '' 
      parsed_message = JSON.parse(job_message)
      @route_buffer.update_buffer(parsed_message)
      available_routes = @route_buffer.available_routes
        
      #look at complete jobs
      available_routes.each do |job_id|
        puts "route '#{job_id}' is ready!"
        route_to_draw = @route_buffer.route(job_id)
        puts route_to_draw
        draw_route(parsed_message['job_id'], route_to_draw['route'].split("\n"),route_to_draw['map'])
        @route_buffer.remove_route(parsed_message['job_id'])
      end
    end
  end
  
  def draw_route(job_id, route_points, map_points)
    begin
      text = File.read(Configuration.route_template_location + 'route_template.html')
      
      #output route
      replacement_string = ''
      route_points.each do |line|
        xval = line.split(',')[1]
        yval = line.split(',')[3]
        replacement_string+="[#{xval},#{yval}],"
      end
      
      replacement_string = replacement_string[0...-1]
      new_contents = text.gsub(/@@@LINE_ARRAY@@@/, replacement_string)
      
      #output blockers      
      replacement_string = ''
      row_count = 0
      col_count = 0
      lines = map_points.split("\n")
      lines.each do |line|
        col_count = 0
        cols = line.split(',')
        puts "LINE:#{line}"
        cols.each do |col|
          puts "COL:#{col}"
          if col == '1'
            replacement_string+="[#{col_count},#{row_count}],"
          end
          col_count = col_count + 1
        end
        row_count = row_count + 1
      end
      
      replacement_string = replacement_string[0...-1]
      new_contents = new_contents.gsub(/@@@BLOCKED_ARRAY@@@/, replacement_string)
      
      route_file_name=Time.now.strftime("%H_%M_%S")
      
      route_output_file="#{Configuration.route_template_location}#{job_id}_#{route_file_name}.html"
      File.open(route_output_file, 'w') do |file| 
          file.puts(new_contents)
      end
      puts "Written route to #{route_output_file}"
  	rescue Exception => e  
  	  puts e.message  
  	  puts e.backtrace.inspect 
      raise 'Failed route receive' 
  	end  
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
