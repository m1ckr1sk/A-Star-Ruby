require_relative 'astar'

astar = AStarLibrary.new
astar.InitializePathfinder

pathfinder_id = 1
astar.FindPath(pathfinder_id,0,0,50,50)
astar.FindPath(2,5,5,50,5)

for i in 1..astar.path_length(pathfinder_id) do
  puts "X,#{astar.ReadPathX(pathfinder_id,i)}, Y,#{astar.ReadPathY(pathfinder_id,i)}"
end

for i in 1..astar.path_length(2) do
  puts "X,#{astar.ReadPathX(2,i)},Y,#{astar.ReadPathY(2,i)}"
end

