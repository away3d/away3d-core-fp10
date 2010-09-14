package away3d.core.geom
{
	import flash.geom.*;
	
	public class PathCommand
	{
		public static const MOVE:String = "M";
		public static const LINE:String = "L";
		public static const CURVE:String = "C";
		
		/**
		 * 
		 */
		public var pStart:Vector3D;
		
		/**
		 * 
		 */
		public var pControl:Vector3D;
		
		/**
		 * 
		 */
		public var pEnd:Vector3D;
		
		/**
		 * 
		 */
		public var type:String;
		
		public function PathCommand(type:String, pStart:Vector3D = null, pControl:Vector3D = null, pEnd:Vector3D = null)
		{
			this.type = type;
			this.pStart = pStart;
			this.pControl = pControl;
			this.pEnd = pEnd;
		}
		
		public function toString():String
		{
			return "PathCommand: " + type + ", " + pStart + ", " + pControl + ", " + pEnd;
		}
	}
}