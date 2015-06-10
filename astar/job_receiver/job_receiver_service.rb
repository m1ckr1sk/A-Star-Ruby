require 'json'
require_relative 'astar_map'
require_relative 'astar'


class JobReceiverService
  def initialize(plumbing_adapter)
    @plumbing_adapter = plumbing_adapter
    @plumbing_adapter.register_topic('route')
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
        check_jobs
        check_config
        check_heartbeat
      end while @poll
    }  
  end
  
  def check_jobs
    job_message = @plumbing_adapter.get_message('route') 
    if job_message != '' 
      message = JSON.parse(job_message)
      process_map(message["job_id"], message["start_point"], message["end_point"], message["map"])
    end
  end
  
  def check_config
    config_message = @plumbing_adapter.get_message('config')
    if config_message != ''
      @plumbing_adapter.send_message('config', 'job_receiver_config...')
    end
  end
  
  def check_heartbeat 
    if( (Time.now - @heartbeat) > 60) then
      @heartbeat = Time.now
      @plumbing_adapter.send_message('heartbeat', 'job_receiver_heartbeat...')
    end
  end
  
  def process_map(job_id, start_point, end_point, map_string)
    puts "Processing Map"
    lines = map_string.split("\n")
    columns = lines[0].split(',')
    
    astar_map = AStarMap.new(columns.length,lines.length)
    
    file_name=Time.now.strftime("%H_%M_%S")+'.csv'
    File.open("#{file_name}", 'w') do |file| 
      for i in 1..lines.length do
          file.write("#{lines[i]}\n")
      end
    end		
    
    astar_map.load_walkability(file_name)
    pathfinder_id = 1
    astar = AStarLibrary.new(astar_map)
    astar.InitializePathfinder
    start_array= start_point.split(',')
    end_array= end_point.split(',')
    astar.FindPath(pathfinder_id,start_array[1].to_i,start_array[3].to_i,end_array[1].to_i,end_array[3].to_i)
    
    route = ''
    for i in 1..astar.path_length(pathfinder_id) do
      route.concat("X,#{astar.ReadPathX(pathfinder_id,i)},Y,#{astar.ReadPathY(pathfinder_id,i)}\n")
    end
    
    route_hash=Hash.new
    route_hash['job_id'] = job_id
    route_hash['value'] = route
    route_hash['message'] = 'route'
    route_message=route_hash.to_json
    
    @plumbing_adapter.send_message('routed',route_message)
  end
  
  def stop
    @poll = false
    @thread_main.join
    @plumbing_adapter.close
  end
end