class AStarMap
	
	WALKABLE=0
    UNWALKABLE=1

	def initialize
		@MapWidth = 80
		@MapHeight = 60
		
		@terrainCost=Array.new(@MapWidth+1){Array.new(@MapHeight+1)}
		@walkability=Array.new(@MapWidth){Array.new(@MapHeight)}
		@terrainHeight=Array.new(@MapWidth +1){Array.new(@MapHeight+1)}
	end
	
	def width
		return @MapWidth
	end
	
	def height
		return @MapHeight
	end
	
	def walkability(x, y)
		return @walkability[x][x]
	end
end