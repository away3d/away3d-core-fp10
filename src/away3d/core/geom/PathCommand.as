package away3d.core.geom
{
	import away3d.core.math.*;
	
	public class PathCommand
	{
		public static const MOVE:String = "M";
		public static const LINE:String = "L";
		public static const CURVE:String = "C";
		
		/**
		 * 
		 */
		public var pStart:Number3D;
		
		/**
		 * 
		 */
		public var pControl:Number3D;
		
		/**
		 * 
		 */
		public var pEnd:Number3D;
		
		/**
		 * 
		 */
		public var type:String;
		
		public function PathCommand(type:String, pStart:Number3D = null, pControl:Number3D = null, pEnd:Number3D = null)
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