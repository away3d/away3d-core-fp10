package away3d.core.vos 
{
	import away3d.core.base.*;
	import away3d.materials.*;
	
	/**
	 * @author robbateman
	 */
	public class ElementVO 
	{
		public var commands:Vector.<String> = new Vector.<String>();
		
		public var vertices:Vector.<Vertex> = new Vector.<Vertex>();
		
		public var screenZ:Number;
		
		public var material:Material;
	}
}
