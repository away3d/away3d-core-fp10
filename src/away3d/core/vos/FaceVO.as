package away3d.core.vos
{
	
	import away3d.core.base.*;
	import away3d.materials.*;
	
	public class FaceVO extends ElementVO
	{
		public var generated:Boolean;
		
		public var uvs:Vector.<UV> = new Vector.<UV>();
		
		public var back:Material;
		
		public var face:Face;
		
		public var reverseArea:Boolean;
	}
}