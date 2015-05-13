require "bunny"

# Require configuration
require_relative 'configuration'

def draw_route(lines)
  text = File.read('route_template.html')
  replacement_string = ''
  lines.each do |line|
    xval = line.split(',')[1]
    yval = line.split(',')[3]
    
    replacement_string+="context.lineTo(#{xval},#{yval});\n"
  end
  new_contents = text.gsub(/@@@LINE_ARRAY@@@/, replacement_string)
  route_file_name=Time.now.strftime("%H_%M_%S")
  route_output_file="#{route_file_name}.html"
  File.open(route_output_file, 'w') do |file| 
			file.puts(new_contents)
  end
  puts "Written route to #{route_output_file}"
end

conn = Bunny.new(Configuration.rabbitmq_url, automatically_recover: false)
conn.start

ch   = conn.create_channel
q    = ch.queue("routed")

begin
  puts " [*] Final receiver ------"
  puts " [*] Receiving processed messages..."
  puts " [*] To exit press CTRL+C"
  q.subscribe(:block => true) do |delivery_info, properties, body|
    #puts " [x] Received '#{body}'"
    lines = body.split("\n")
    draw_route(lines)
  end
rescue Interrupt => _
  conn.close

  exit(0)
end