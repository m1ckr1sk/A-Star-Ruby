require 'bunny'
require 'json'
require_relative 'astar_map'
require_relative 'astar'

def send_message(data, queue)
  send_conn = Bunny.new(Configuration.rabbitmq_url, :automatically_recover => false)
  send_conn.start
  send_ch = send_conn.create_channel
  send_q = send_ch.queue(queue)
  send_ch.default_exchange.publish(data, :routing_key => send_q.name, :persistent => true)
  puts " [x] Processed '#{data}'"
  send_conn.close
end

def process_map(start_point, end_point, map_string)
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
  send_message(route,"routed")
end

# Require configuration
require_relative '../configuration'

conn = Bunny.new(Configuration.rabbitmq_url, automatically_recover: false)
conn.start

ch   = conn.create_channel
q    = ch.queue("route")

begin
  puts " [*] Final receiver ------"
  puts " [*] Receiving processed messages..."
  puts " [*] To exit press CTRL+C"
  q.subscribe(:block => true) do |delivery_info, properties, body|
    puts " [x] Received '#{body}'"
    message = JSON.parse(body)
    puts " [x] start '#{message["start_point"]}'"
    puts " [x] end '#{message["end_point"]}'"
    process_map(message["start_point"], message["end_point"], message["map"])
    
  end
rescue Interrupt => _
  conn.close

  exit(0)
end