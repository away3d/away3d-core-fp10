package awaybuilder.events
{
	import flash.events.Event;
	
	
	
	public class GeometryEvent extends Event
	{
		static public const DOWN : String = "down" ;
		static public const MOVE : String = "move" ;
		static public const OUT : String = "out" ;
		static public const OVER : String = "over" ;
		static public const UP : String = "up" ;
		static public const COLLADA_COMPLETE : String = "colladaComplete" ;
		
		public var data : * ;
		
		
		
		public function GeometryEvent ( type : String , bubbles : Boolean = true , cancelable : Boolean = false )
		{
			super ( type , bubbles , cancelable ) ;
		}
	}
}