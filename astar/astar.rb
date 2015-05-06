require_relative 'astar_map'

class AStarLibrary

    PATH_NOT_STARTED=0
    PATH_FOUND=1
    PATH_NON_EXISTANT=2
    
    def initialize(astar_map)
		@astar_map = astar_map
		@NumberPeople = 1
    end
    
    def path_length(pathfinder_id)
      return @pathLength[pathfinder_id]
    end

    def InitializePathfinder
      @onClosedList = 10
      @notfinished = 0

      @openList = Array.new(@astar_map.width * @astar_map.height + 2)
      @whichList=Array.new(@astar_map.width){Array.new(@astar_map.height)}
      @openX = [@astar_map.width * @astar_map.height + 2]
      @openY = [@astar_map.width * @astar_map.height + 2]
      @parentX=Array.new(@astar_map.width){Array.new(@astar_map.height)} 
      @parentY=Array.new(@astar_map.width){Array.new(@astar_map.height)} 
      @fcost=Array.new(@astar_map.width * @astar_map.height + 2)
      @gcost=Array.new(@astar_map.width){Array.new(@astar_map.height)} 
      @hcost=Array.new(@astar_map.width * @astar_map.height + 2)
      @pathLength=Array.new(@NumberPeople+1)
      @pathLocation=Array.new(@NumberPeople+1)
      @pathbank=Array.new(@astar_map.width){Array.new(@astar_map.height)} 
      @pathStatus=Array.new(@NumberPeople+1)
      @xPath=Array.new(@NumberPeople+1)
      @yPath=Array.new(@NumberPeople+1)
    
      @pathBank = Hash.new
      for x in 0..@NumberPeople do
        @pathBank[x] = Array.new(@astar_map.width * @astar_map.height)
      end
 
    end
    
    def FindPath(pathfinderID,startingX,startingY,targetX,targetY)
    
      onOpenList = 0
      parentXval = 0
      parentYval = 0
      a = 0
      b = 0
      m = 0
      u = 0
      v = 0
      temp = 0
      corner = 0
      numberOfOpenListItems = 0
      addedGCost = 0
      tempGcost = 0
      path = 0
      tempx = 0 
      pathX= 0 
      pathY= 0 
      cellPosition= 0
      newOpenListItemID = 0

      #1. Convert location data (in pixels) to coordinates in the walkability array.
      startX = startingX
      startY = startingY
      targetX = targetX
      targetY = targetY

      #2.Quick Path Checks: Under the some circumstances no path needs to
      #	be generated ...
	  quick_path_test_result = quick_path_test(startX,targetX,startY,targetY,@pathLocation[pathfinderID],@astar_map.walkability(targetX,targetY))
	  
	  if quick_path_test_result != PATH_NOT_STARTED then
		return quick_path_test_result
	  end

      #3.Reset some variables that need to be cleared
      if (@onClosedList > 1000000) #reset whichList occasionally
      
        for x in 0..@astar_map.width do
        
          for y in 0..@astar_map.height do
            @whichList[x][y] = 0
          end
          
        end
        
        onClosedList = 10
      end

      #changing the values of onOpenList and onClosed list is faster than redimming whichList() array
      @onClosedList = @onClosedList + 2
      onOpenList = @onClosedList - 1

      #i.e, = 0
      @pathLength[pathfinderID] = PATH_NOT_STARTED

      #i.e, = 0
      @pathLocation[pathfinderID] = PATH_NOT_STARTED

      #reset starting square's G value to 0
      @gcost[startX][startY] = 0

      #4.Add the starting location to the open list of squares to be checked.
      numberOfOpenListItems = 1

      #assign it as the top (and currently only) item in the open list, which is maintained as a binary heap (explained below)
      @openList[1] = 1
      @openX[1] = startX
      @openY[1] = startY

      #5.Do the following until a path is PATH_FOUND or deemed PATH_NON_EXISTANT.
      begin

        #6.If the open list is not empty, take the first cell off of the list.
        #	This is the lowest F cost cell on the open list.
        if (numberOfOpenListItems != 0) then
        
          #7. Pop the first item off the open list.
          parentXval = @openX[@openList[1]]
          parentYval = @openY[@openList[1]] #record cell coordinates of the item
          @whichList[parentXval][parentYval] = @onClosedList #add the item to the closed list

          #	Open List = Binary Heap: Delete this item from the open list, which
          #  is maintained as a binary heap. 
          numberOfOpenListItems = numberOfOpenListItems - 1 #reduce number of open list items by 1	

          #	Delete the top item in binary heap and reorder the heap, with the lowest F cost item rising to the top.
          @openList[1] = @openList[numberOfOpenListItems + 1] #move the last item in the heap up to slot #1
          v = 1

          #	Repeat the following until the new item in slot #1 sinks to its proper spot in the heap.
          begin
            u = v
            if (2 * u + 1 <= numberOfOpenListItems) then #if both children exist
            
              # Check if the F cost of the parent is greater than each child.
              # Select the lowest of the two children.
              if (@fcost[@openList[u]] >= @fcost[@openList[2 * u]]) then
                v = 2 * u
              end
              if (@fcost[@openList[v]] >= @fcost[@openList[2 * u + 1]]) then
                v = 2 * u + 1
              end
            elsif
              if (2 * u <= numberOfOpenListItems) then #if only child #1 exists
                # Check if the F cost of the parent is greater than child #1	
                if (@fcost[@openList[u]] >= @fcost[@openList[2 * u]]) then
                  v = 2 * u
                end
              end
            end

            if (u != v) then #if parent's F is > one of its children, swap them
              temp = @openList[u]
              @openList[u] = @openList[v]
              @openList[v] = temp
            else
              break # otherwise, exit loop
            end
          end while (true) # reorder the binary heap


          #7.Check the adjacent squares. (Its "children" -- these path children
          #	are similar, conceptually, to the binary heap children mentioned
          #	above, but don't confuse them. They are different. Path children
          #	are portrayed in Demo 1 with grey pointers pointing toward
          #	their parents.) Add these adjacent child squares to the open list
          #	for later consideration if appropriate (see various if statements
          #	below).
          for b in (parentYval - 1)..(parentYval + 1) do
          
            for a in (parentXval - 1)..(parentXval + 1) do
            
              #	If not off the map (do this first to avoid array out-of-bounds errors)
              if (a != -1 && b != -1 && a != @astar_map.width && b != @astar_map.height) then
              
                #	If not already on the closed list (items on the closed list have
                #	already been considered and can now be ignored).			
                if (@whichList[a][b] != @onClosedList) then
                
                  #	If not a wall/obstacle square.
                  if (@astar_map.walkability(a,b) != AStarMap::UNWALKABLE) then
                  
                    #	Don't cut across corners
                    corner = AStarMap::WALKABLE
                    if (a == parentXval - 1) then
                      if (b == parentYval - 1) then
                        if (@astar_map.walkability(parentXval - 1,parentYval) == AStarMap::UNWALKABLE || @astar_map.walkability(parentXval,parentYval - 1) == AStarMap::UNWALKABLE) then
                          corner = AStarMap::UNWALKABLE
                        end
                      elsif(b == parentYval + 1)
                        if (@astar_map.walkability(parentXval, parentYval + 1) == AStarMap::UNWALKABLE || @astar_map.walkability(parentXval - 1, parentYval) == AStarMap::UNWALKABLE) then
                          corner = AStarMap::UNWALKABLE
                        end
                      end
                    elsif(a == parentXval + 1)
                    
                      if (b == parentYval - 1) then
                      
                        if (@astar_map.walkability(parentXval, parentYval - 1) == AStarMap::UNWALKABLE || @astar_map.walkability(parentXval + 1, parentYval) == AStarMap::UNWALKABLE) then
                          corner = AStarMap::UNWALKABLE 
                        end
                        
                      elsif (b == parentYval + 1)
                      
                        if (@astar_map.walkability(parentXval + 1, parentYval) == AStarMap::UNWALKABLE || @astar_map.walkability(parentXval, parentYval + 1) == AStarMap::UNWALKABLE)
                          corner = AStarMap::UNWALKABLE
                        end
                      end
                    end
                    
                    if (corner == AStarMap::WALKABLE) then

                      #	If not already on the open list, add it to the open list.			
                      if (@whichList[a][b] != onOpenList) then

                        #Create a new open list item in the binary heap.
                        newOpenListItemID = newOpenListItemID + 1 #each new item has a unique ID #
                        m = numberOfOpenListItems + 1
                        @openList[m] = newOpenListItemID #place the new open list item (actually, its ID#) at the bottom of the heap
                        @openX[newOpenListItemID] = a
                        @openY[newOpenListItemID] = b #record the x and y coordinates of the new item

                        #Figure out its G cost
                        if ((a - parentXval).abs == 1 && (b - parentYval).abs == 1)
                        
                          #cost of going to diagonal squares	
                          addedGCost = 14
                        else
                        
                          #cost of going to non-diagonal squares	
                          addedGCost = 10
                        end

                        # Uphill downhill
                        #parentHeight = this.terrainHeight[parentXval][parentYval]
                        #childHeight = this.terrainHeight[a][b]
                        #gradient = parentHeight - childHeight;
                        #if (gradient < 0) then
                          #cost of going uphill
                          #addedGCost += gradient.abs
                        #end

                        # Add terrain cost
                        #addedGCost += @terrainCost[a][b]

                        @gcost[a][b] = @gcost[parentXval][parentYval] + addedGCost

                        #Figure out its H and F costs and parent
                        @hcost[@openList[m]] = 10 * ((a - targetX).abs + (b - targetY).abs)
                        @fcost[@openList[m]] = @gcost[a][b] + @hcost[@openList[m]]
                        @parentX[a][b] = parentXval
                        @parentY[a][b] = parentYval

                        #Move the new open list item to the proper place in the binary heap.
                        #Starting at the bottom, successively compare to parent items,
                        #swapping as needed until the item finds its place in the heap
                        #or bubbles all the way to the top (if it has the lowest F cost).
                        while (m != 1) do #While item hasn't bubbled to the top (m=1)	
                        
                          #Check if child's F cost is < parent's F cost. If so, swap them.	
                          if (@fcost[@openList[m]] <= @fcost[@openList[m / 2]]) then
                            temp = @openList[m / 2]
                            @openList[m / 2] = @openList[m]
                            @openList[m] = temp
                            m = m / 2
                          else
                            break
                          end
                        end
                        numberOfOpenListItems = numberOfOpenListItems + 1 # add one to the number of items in the heap

                        # Change whichList to show that the new item is on the open list.
                        @whichList[a][b] = onOpenList

                      #8.If adjacent cell is already on the open list, check to see if this 
                      #	path to that cell from the starting location is a better one. 
                      #	If so, change the parent of the cell and its G and F costs.	
                      else #If whichList(a,b) = onOpenList
                      
                        #Figure out the G cost of this possible new path
                        if ((a - parentXval).abs == 1 && (b - parentYval).abs == 1)
                          addedGCost = 14 # cost of going to diagonal tiles	
                        else
                          addedGCost = 10 # cost of going to non-diagonal tiles	
                        end

                        # Add terrain cost
                        #addedGCost += @terrainCost[a][b]

                        # Uphill downhill
                        #parentHeight = this.terrainHeight[parentXval][parentYval]
                        #childHeight = this.terrainHeight[a][b]
                        #gradient = parentHeight - childHeight
                        #if (gradient < 0)
                          #cost of going uphill
                        #  addedGCost += (gradient).abs
                        #end


                        tempGcost = @gcost[parentXval][parentYval] + addedGCost

                        #If this path is shorter (G cost is lower) then change
                        #the parent cell, G cost and F cost. 		
                        if (tempGcost < @gcost[a][b]) #if G cost is less,

                          @parentX[a][b] = parentXval #change the square's parent
                          @parentY[a][b] = parentYval
                          @gcost[a][b] = tempGcost #change the G cost			

                          #Because changing the G cost also changes the F cost, if
                          #the item is on the open list we need to change the item's
                          #recorded F cost and its position on the open list to make
                          #sure that we maintain a properly ordered open list.
                          for x in 1..numberOfOpenListItems do #look for the item in the heap
                  
                            if (@openX[@openList[x]] == a && @openY[@openList[x]] == b) #item PATH_FOUND
                            
                              @fcost[@openList[x]] = @gcost[a][b] + @hcost[@openList[x]] #change the F cost

                              #See if changing the F score bubbles the item up from it's current location in the heap
                              m = x
                              while (m != 1) do #While item hasn't bubbled to the top (m=1)	
                              
                                #Check if child is < parent. If so, swap them.	
                                if (@fcost[@openList[m]] < @fcost[@openList[m / 2]])
                                  temp = @openList[m / 2]
                                  @openList[m / 2] = @openList[m]
                                  @openList[m] = temp
                                  m = m / 2
                                else
                                  break
                                end
                              end
                              break #exit for x = loop
                            end #If @openX(@openList(x)) = a
                          end #For x = 1 To numberOfOpenListItems
                        end #If tempGcost < @gcost(a,b)

                      end #else If whichList(a,b) = onOpenList	
                    end #If not cutting a corner
                  end #If not a wall/obstacle square.
                end #If not already on the closed list 
              end #If not off the map
            end #for (a = parentXval-1; a <= parentXval+1; a++){
          end #for (b = parentYval-1; b <= parentYval+1; b++){

        #9.If open list is empty then there is no path.	
        else
          @pathStatus[pathfinderID] = PATH_NON_EXISTANT
          break
        end

        #If target is added to open list then path has been PATH_FOUND.
        if (@whichList[targetX][targetY] == onOpenList)
          @pathStatus[pathfinderID] = PATH_FOUND
          break
        end

      end while (true) #Do until path is PATH_FOUND or deemed PATH_NON_EXISTANT

      #10.Save the path if it exists.
      if (@pathStatus[pathfinderID] == PATH_FOUND)

        
        #a.Working backwards from the target to the starting location by checking
        #	each cell's parent, figure out the length of the path.
        pathX = targetX 
        pathY = targetY

        begin
          #Look up the parent of the current cell.	
          tempx = @parentX[pathX][pathY]
          pathY = @parentY[pathX][pathY]
          pathX = tempx

          #Figure out the path length
          @pathLength[pathfinderID] = @pathLength[pathfinderID] + 1
        end while (pathX != startX || pathY != startY)

        #c. Now copy the path information over to the databank. Since we are
        #	working backwards from the target to the start location, we copy
        #	the information to the data bank in reverse order. The result is
        #	a properly ordered set of path data, from the first step to the
        #	last.
        pathX = targetX
        pathY = targetY
        cellPosition = @pathLength[pathfinderID] * 2 #start at the end	
        begin
          
          cellPosition = cellPosition - 2 #work backwards 2 integers
          @pathBank[pathfinderID][cellPosition] = pathX
          @pathBank[pathfinderID][cellPosition + 1] = pathY

          #d.Look up the parent of the current cell.	
          tempx = @parentX[pathX][pathY]
          pathY = @parentY[pathX][pathY]
          pathX = tempx

          #e.If we have reached the starting square, exit the loop.	
        end while (pathX != startX || pathY != startY)
        
      end
      return @pathStatus[pathfinderID]
  
    end
	
	def quick_path_test(startX, targetX, startY, targetY, path_location, target_walkable_state)
	  #	If starting location and target are in the same location...
      if (startX == targetX && startY == targetY && path_location > 0) then
        return PATH_FOUND
      end
      
      if (startX == targetX && startY == targetY && path_location == 0) then
        return PATH_NON_EXISTANT
      end

      #	If target square is UNWALKABLE, return that it's a PATH_NON_EXISTANT path.
      if (target_walkable_state == AStarMap::UNWALKABLE) then
        noPath
        return PATH_NON_EXISTANT
      end
	  
	  return PATH_NOT_STARTED
	end

    #13.If there is no path to the selected target, set the pathfinder's
    #	xPath and yPath equal to its current location and return that the
    #	path is PATH_NON_EXISTANT.
    def noPath
      @xPath[pathfinderID] = startingX;
      @yPath[pathfinderID] = startingY;
    end

    #The following two functions read the raw path data from the pathBank.
    #You can call these functions directly and skip the readPath function
    #above if you want. Make sure you know what your current @pathLocation
    #is.
    def ReadPathX(pathfinderID, pathLocation)

      x = -1
      if (pathLocation <= @pathLength[pathfinderID])
      
        #Read coordinate from bank
        x = @pathBank[pathfinderID][pathLocation * 2 - 2]
        
      end
      return x
    end

    def ReadPathY( pathfinderID, pathLocation)
      y = -1
      if (pathLocation <= @pathLength[pathfinderID])

        #Read coordinate from bank
        y = @pathBank[pathfinderID][pathLocation * 2 - 1]

      end
      return y
    end

    
end



