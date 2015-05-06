class PathWriter
	def write_path(path_file, astar, pathfinder_id)
		
		File.open(path_file, 'w') do |file| 
			for i in 1..astar.path_length(pathfinder_id) do
				file.write("X,#{astar.ReadPathX(pathfinder_id,i)},Y,#{astar.ReadPathY(pathfinder_id,i)}\n")
			end
		end		
	end
end