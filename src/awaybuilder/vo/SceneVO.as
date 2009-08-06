package awaybuilder.vo
{
	import awaybuilder.interfaces.IValueObject;	
	
	import flash.display.Sprite;
	
	import away3d.containers.View3D;
	
	
	
	public class SceneVO implements IValueObject
	{
		public var id : String ;
		public var name : String ;
		public var container : Sprite ;
		public var cameras : Array ;
		public var geometry : Array ;
		public var sections : Array ;
		public var view : View3D ;
		public var cameraOrigin : SceneObjectVO ;
		public var cameraTarget : SceneObjectVO ;
		public var zoom : Number ;
		public var focus : Number ;
		public var materials : Array ;
		
		
		
		public function SceneVO ( )
		{
			this.cameras = new Array ( ) ;
			this.geometry = new Array ( ) ;
			this.sections = new Array ( ) ;
			this.materials = new Array ( ) ;
		}
	}
}