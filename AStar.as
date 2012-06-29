// ActionScript file
//this is a helper class that implements the A* pathfinding algorithm.
//It will find the best path from start to dest on the target map and
//return an array of points(map coordinates) to follow.
package 
{
	import flash.geom.Point;

	public final class AStar
	{
		protected static var open:Array = null;
		protected static var closed:Array = null;
		protected static var DIAGONAL:int = 14;
		protected static var ALIGNED:int = 10;
		
		protected static function sortOnFCost(a:AStarNode, b:AStarNode):Number
		{
			var aFCost:Number = a.f;
			var bFCost:Number = b.f;
			
			if(aFCost < bFCost) {
				return -1;
			}
			else if(aFCost > bFCost) {
				return 1;
			}
			else {
				return 0;
			}
			
		}
		
		public static function GetPath(map:Map, start:Point, dest:Point):Array
		{
			//only if the map was loaded
			if(map.MapLoaded)
			{
				//if destination is not walkable, return no path
				//or destination is start return null
				if(!map.CheckWalkable(dest.x, dest.y) || (start.x == dest.x && start.y == dest.y))
					return null;
					
				open = [];
				closed = [];
				open = new Array();
				closed = new Array();
				
				var current:AStarNode = null;
				
				//add start coordinate to the open list
				var startNode:AStarNode = new AStarNode();
				startNode.g = 0;
				startNode.h = getHCost(start, dest);
				startNode.f = startNode.g + startNode.h;
				startNode.thisPosition = start;
				startNode.parentNode = startNode;
				open.push(startNode);
				
				//loop untill the path is found
				//or untill we found out the path is not possible
				do
				{
					//open is sorted by f cost
					//current node is the one with lowest f cost, or first in array
					current = open[0];
					//move node into the closed list and remove from open list	
					closed.push(open[0]);
					open.splice(0,1);
					//if we got to the destination node, break out of the loop
					//we found the path
					if(current.thisPosition.x == dest.x && current.thisPosition.y == dest.y)
						break;
																				
					//find the 8 adjacent nodes
					for(var i:int = 1; i <= 8; i++)
					{
						//tilewalk to each adjacent node from current
						var thisPos:Point = TileWalker.IsoStaggeredTileWalker(current.thisPosition, i);
						//skip this node if this position is not walkable or
						//if its on the closed list
						if(map.CheckWalkable(thisPos.x, thisPos.y) &&
							findLocInClosed(thisPos) == -1)
						{
							var thisPosInOpen:int = findLocInOpen(thisPos);
							if(thisPosInOpen == -1)
							{
								var thisNode:AStarNode = new AStarNode();
								thisNode.thisPosition = thisPos.clone();
								thisNode.parentNode = current;
								thisNode.g = getGCost(thisPos, current.thisPosition);
								thisNode.h = getHCost(thisPos, dest);
								thisNode.f = thisNode.g + thisNode.h;
								open.push(thisNode);
							}
							else
							{
								var newG:int = getGCost(thisPos, current.thisPosition);
								var total:int = newG + current.g;
								if(total < open[thisPosInOpen].g)
								{
									open[thisPosInOpen].parentNode = current;
									open[thisPosInOpen].g = getGCost(thisPos, current.thisPosition);
									open[thisPosInOpen].f = open[thisPosInOpen].g + open[thisPosInOpen].h;
								}
								/*if(open[thisPosInOpen].g < current.g)
								{
									open[thisPosInOpen].parentNode = current;
									open[thisPosInOpen].g = getGCost(thisPos, current.thisPosition);
									open[thisPosInOpen].h = getGCost(thisPos, dest);
									open[thisPosInOpen].f = open[thisPosInOpen].g + open[thisPosInOpen].h;
								}*/
							}
						}
					} 
					//re-sort open list by f score
					sortOpenList();
					
				//loop while there are no more nodes in the open list
				}while(open.length > 0 )
				
				//gather the steps to get from start to end in an array of Points
				var steps:Array = new Array();
				
				//see if the dest is in the closed list,
				//if not then no path was found
				//if yes than compile the list of steps
				var lastStepIndex:int = findLocInClosed(dest);
				if(lastStepIndex == -1)
					return null;
					
				var thisStep:AStarNode = closed[lastStepIndex];
				steps.push(thisStep.thisPosition);
				//loop through all steps
				while(1)
				{
					//get the current position and push into array
					thisStep = thisStep.parentNode;
					steps.push(thisStep.thisPosition);
					
					//when we reach start, break
					if(thisStep.thisPosition.x == start.x && thisStep.thisPosition.y == start.y)
						break;
				}
				//reverse the array
				//array was from end to start, now from start to end
				//but remove the start position, don't need it
				//we just need the positions to get to the dest,
				//we already know the start position
				steps.reverse();
				steps.splice(0,1);
				
				return steps;
			}
			return null;
		}
		
		protected static function getGCost(start:Point, end:Point):int
		{
			var g:int = 0;

			if(Math.abs(end.y-start.y) % 2 == 1)
				g = ALIGNED;
			else
				g = DIAGONAL;
			return g;
			
			/*if (( start.x - end.x ) && ( start.y - end.y )) // diagonal movement
				return 14;

			return 10;*/
		}
		
		protected static function getHCost(start:Point, end:Point):int
		{
			/*var a1:int = 2*start.x;
        	var a2:int =  2*start.y+start.x%2 - start.x;
        	var a3:int = -2*start.y-start.x%2 - start.x; // == -a1-a2
        	var b1:int = 2*end.x;
       		var b2:int =  2*end.y+end.x%2 - end.x;
       		var b3:int = -2*end.y-end.x%2 - end.x; // == -b1-b2

       	 	// One step on the map is 10 in this function
       	 	var dis:int = 5*Math.max(Math.abs(a1-b1), Math.max(Math.abs(a2-b2), Math.abs(a3-b3)));
			return dis;*/
			var abs1:Number = Math.abs(end.x-start.x);//end.x - start.x > 0 ? end.x - start.x : start.x - end.x;
			var abs2:Number = Math.abs(end.y-start.y);//end.y - start.y > 0 ? end.y - start.y : start.y - end.y;
			var Result:Number = Math.min(abs1, abs2)*DIAGONAL;//abs1 < abs2 ? abs1 * 14 : abs2 * 14; // min(|dx|,|dy|)
			Result += Math.abs(abs1-abs2)*ALIGNED;//abs1 > abs2 ? (abs1 - abs2) * 10 : (abs2 - abs1) * 10; // ||dx|-|dy||
			return Result;
		}
		
		protected static function findLocInOpen(loc:Point):int
		{
			for(var i:int = 0;i < open.length; i++)
			{
				if(open[i].thisPosition.x == loc.x && open[i].thisPosition.y == loc.y)
					return i;
			}
			return -1;
		}
		
		protected static function findLocInClosed(loc:Point):int
		{
			for(var i:int = 0;i < closed.length; i++)
			{
				if(closed[i].thisPosition.x == loc.x && closed[i].thisPosition.y == loc.y)
				{
					return i;
				}
			}
			return -1;
		}
		
		protected static function sortOpenList():void
		{
			open.sort(sortOnFCost);
		}
	}
}