class PathLoader
	def load_path(path_file)
		path_array = Array.new
		f = File.open(path_file) or die "Unable to open file...#{path_file}"
		f.each_line do |line|
			line_array = line.split(',')
			path_array << line_array[1].to_i
			path_array << line_array[3].to_i
		end
		return path_array
	end
end