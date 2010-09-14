package away3d.modifiers.data 
{
	import away3d.core.base.*;
	
	import flash.geom.*;
	
	/**
	 * @author robbateman
	 */
	public class VertexData 
	{
		public var vertex:Vertex;
		public var origin:Vector3D = new Vector3D();
		public var position:Vector3D = new Vector3D();
		public var normal:Vector3D = new Vector3D();
		public var uvs:Array = new Array();
		public var offset:Number = 0;
	}
}
