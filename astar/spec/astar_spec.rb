require_relative '..\astar'
require_relative 'helpers\path_loader'
require_relative 'helpers\path_writer'

describe 'astar' do

before(:each) do
    @path_loader = PathLoader.new
    @path_writer = PathWriter.new
end

it 'should return a direct path when no obstacles in its way in a 10x10 map' do
	
	#arrange
	astar_map = AStarMap.new(10,10)
  astar_map.load_walkability("spec/test_data/straight_route/map_10_clear.csv")
  
	astar = AStarLibrary.new(astar_map)
	astar.InitializePathfinder
	pathfinder_id=1
	
	expected_path = @path_loader.load_path "spec/test_data/straight_route/expected_straight_route_10.csv"
	
	#act
	astar.FindPath(pathfinder_id,0,0,9,9)
	@path_writer.write_path("spec/test_data/straight_route/actual_straight_route_10.csv",astar,pathfinder_id)
	actual_path = @path_loader.load_path "spec/test_data/straight_route/actual_straight_route_10.csv"
	
	#assert
	puts "EXPECTING: #{expected_path}"
	puts "GOT: #{actual_path}"
	expect(actual_path).to eq(expected_path)
end

it 'should return a direct path when no obstacles in its way in a 10x20 map' do
	
	#arrange
	astar_map = AStarMap.new(10,20)
  astar_map.load_walkability("spec/test_data/straight_route/map_10_20_clear.csv")
  
	astar = AStarLibrary.new(astar_map)
	astar.InitializePathfinder
	pathfinder_id = 1
	
	expected_path = @path_loader.load_path "spec/test_data/straight_route/expected_straight_route_10_20.csv"
	
	#act
	astar.FindPath(pathfinder_id,0,0,9,19)
	@path_writer.write_path("spec/test_data/straight_route/actual_straight_route_10_20.csv",astar,pathfinder_id)
	actual_path = @path_loader.load_path "spec/test_data/straight_route/actual_straight_route_10_20.csv"
	
	#assert
	puts "EXPECTING: #{expected_path}"
	puts "GOT: #{actual_path}"
	expect(actual_path).to eq(expected_path)
end

it 'should return a path when obstacles in its way in a 10x10 map' do
	
	#arrange
	astar_map = AStarMap.new(10,10)
  astar_map.load_walkability("spec/test_data/obstacle_route/map_10_blocked.csv")
  
	astar = AStarLibrary.new(astar_map)
	astar.InitializePathfinder
	pathfinder_id=1
	
	expected_path = @path_loader.load_path "spec/test_data/obstacle_route/expected_blocked_route_10.csv"
	
	#act
	astar.FindPath(pathfinder_id,0,0,9,9)
	@path_writer.write_path("spec/test_data/obstacle_route/actual_blocked_route_10.csv",astar,pathfinder_id)
	actual_path = @path_loader.load_path "spec/test_data/obstacle_route/actual_blocked_route_10.csv"
	
	#assert
	puts "EXPECTING: #{expected_path}"
	puts "GOT: #{actual_path}"
	expect(actual_path).to eq(expected_path)
end

end

