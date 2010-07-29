package away3d.core.vos
{
	
	import away3d.core.base.*;
	import away3d.materials.*;
	
	public class FaceVO extends ElementVO
	{
		public var generated:Boolean;
		
		public var uvs:Array = new Array();
		
		public var back:Material;
		
		public var face:Face;
		
		public var reverseArea:Boolean;
	}
}