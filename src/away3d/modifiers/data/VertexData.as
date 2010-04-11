package away3d.modifiers.data 
{
	import away3d.core.math.*;
	import away3d.core.base.*;
	
	/**
	 * @author robbateman
	 */
	public class VertexData 
	{
		public var vertex:Vertex;
		public var origin:Number3D = new Number3D();
		public var position:Number3D = new Number3D();
		public var normal:Number3D = new Number3D();
		public var uvs:Array = new Array();
		public var offset:Number = 0;
	}
}
