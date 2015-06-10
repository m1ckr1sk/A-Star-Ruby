class AStarMap
	
	WALKABLE=0
  UNWALKABLE=1

	def initialize(width, height)
		@width = width
		@height = height
    
		@walkability=Array.new(@width){Array.new(@height)}
		@terrainCost=Array.new(@width+1){Array.new(@height+1)}
		@terrainHeight=Array.new(@width +1){Array.new(@height+1)}
	end
  
  def load_walkability(walkability_file)
		path_array = Array.new
		f = File.open(walkability_file) or die "Unable to open walkability file...#{walkability_file}"
    
    	line_number = 0
		f.each_line do |line|
			line_array = line.split(',')
      		column_number = 0
      line_array.each do |value|
        @walkability[column_number][line_number] = value.to_i
        column_number += 1
      end
      line_number += 1
		end
	end
	
	def width
		return @width
	end
	
	def height
		return @height
	end
	
	def walkability(x, y)
		return @walkability[x][y]
	end
end