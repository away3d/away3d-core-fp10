package awaybuilder.vo
{
	import awaybuilder.interfaces.IValueObject;	
	
	import away3d.core.base.Object3D;
	import away3d.materials.IMaterial;
	
	
	
	public class SceneGeometryVO implements IValueObject
	{
		public var id : String ;
		public var name : String ;
		public var values : SceneObjectVO ;
		public var geometryExtras : Array = [ ] ;
		public var materialExtras : Array = [ ] ;
		public var material : IMaterial ;
		public var materialBack : IMaterial ;
		public var smooth : Boolean ;
		public var precision : Number = 0 ;
		public var mesh : Object3D ;
		public var enabled : Boolean = true ;
		public var mouseDownEnabled : Boolean ;
		public var mouseMoveEnabled : Boolean ;
		public var mouseOutEnabled : Boolean ;
		public var mouseOverEnabled : Boolean ;
		public var mouseUpEnabled : Boolean ;
		public var geometryType : String ;
		public var materialType : String ;
		public var materialData : Object ;
		public var targetCamera : String ;
		public var flipTexture : Boolean ;
		public var smoothTexture : Boolean ;
		public var useHandCursor : Boolean ;
		public var colladaScale : Number = -1 ;
		
		protected var _assetClass : String ;
		protected var _assetFile : String ;
		protected var _assetFileBack : String ;
		
		
		
		public function SceneGeometryVO ( )
		{
			this.values = new SceneObjectVO ( ) ;
		}

		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Getters and Setters
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		public function set assetClass ( value : String ) : void
		{
			this._assetClass = value ;
			this._assetFile = null ;
		}
		
		
		
		public function get assetClass ( ) : String
		{
			return this._assetClass ;
		}
		
		
		
		public function set assetFile ( value : String ) : void
		{
			this._assetFile = value ;
			this._assetClass = null ;
		}
		
		
		
		public function get assetFile ( ) : String
		{
			return this._assetFile ;
		}
		
		
		
		public function set assetFileBack ( value : String ) : void
		{
			this._assetFileBack = value ;
			this._assetClass = null ;
		}
		
		
		
		public function get assetFileBack ( ) : String
		{
			return this._assetFileBack ;
		}
	}
}