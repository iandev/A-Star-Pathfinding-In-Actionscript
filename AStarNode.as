// ActionScript file
package 
{
	import flash.geom.Point;
	
	public class AStarNode
	{
		public var g:int = 0;
		public var h:int = 0;
		public var f:int = 0;
		public var thisPosition:Point = null;
		public var parentNode:AStarNode = null;
	}
}