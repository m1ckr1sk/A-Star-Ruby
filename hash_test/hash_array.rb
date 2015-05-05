my_path_hash = Hash.new

map_width = 8
map_height = 5

my_first_path = Array.new(map_width) {Array.new(map_height)}
my_second_path = Array.new(map_width) {Array.new(map_height)}

for y in 0..map_height-1 do
	for x in 0..map_width-1 do
		puts "X=#{x}, Y=#{y}"
		puts (y * map_width) + x
		my_first_path[x][y] = (y * map_width) + x
	end
end

my_path_hash["1"] = my_first_path
my_path_hash["2"] = my_second_path

puts "#{my_path_hash['1']}"

