require_relative '..\astar'
require_relative 'helpers\path_loader'
require_relative 'helpers\path_writer'

describe 'astar' do

it 'should return a direct path when no obstacles in its way in a 10x10 map' do
	
	#arrange
	astar = AStarLibrary.new
	astar.InitializePathfinder
	pathfinder_id = 1
	path_loader = PathLoader.new
	path_writer = PathWriter.new
	expected_path = path_loader.load_path "spec/test_data/straight_route/expected_straight_route_10.csv"
	
	#act
	astar.FindPath(pathfinder_id,0,0,10,10)
	path_writer.write_path("spec/test_data/straight_route/actual_straight_route_10.csv",astar,pathfinder_id)
	actual_path = path_loader.load_path "spec/test_data/straight_route/actual_straight_route_10.csv"
	
	#assert
	puts "EXPECTING: #{expected_path}"
	puts "GOT: #{actual_path}"
	expect(actual_path).to eq(expected_path)
end

it 'should return a direct path when no obstacles in its way in a 10x20 map' do
	
	#arrange
	astar = AStarLibrary.new
	astar.InitializePathfinder
	pathfinder_id = 1
	path_loader = PathLoader.new
	path_writer = PathWriter.new
	expected_path = path_loader.load_path "spec/test_data/straight_route/expected_straight_route_10_20.csv"
	
	#act
	astar.FindPath(pathfinder_id,0,0,10,20)
	path_writer.write_path("spec/test_data/straight_route/actual_straight_route_10_20.csv",astar,pathfinder_id)
	actual_path = path_loader.load_path "spec/test_data/straight_route/actual_straight_route_10_20.csv"
	
	#assert
	puts "EXPECTING: #{expected_path}"
	puts "GOT: #{actual_path}"
	expect(actual_path).to eq(expected_path)
end

end

