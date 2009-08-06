package awaybuilder.collada
{
	import awaybuilder.abstracts.AbstractParser;
	import awaybuilder.material.MaterialAttributes;
	import awaybuilder.vo.DynamicAttributeVO;
	import awaybuilder.vo.SceneCameraVO;
	import awaybuilder.vo.SceneGeometryVO;
	import awaybuilder.vo.SceneObjectVO;
	import awaybuilder.vo.SceneSectionVO;
	
	import flash.events.Event;
	
	
	
	public class ColladaParser extends AbstractParser
	{
		public static const GROUP_IDENTIFIER : String = "NODE" ;
		public static const GROUP_CAMERA : uint = 0 ;
		public static const GROUP_GEOMETRY : uint = 1 ;
		public static const GROUP_SECTION : uint = 2 ;
		public static const PREFIX_CAMERA : String = "camera" ;
		public static const PREFIX_GEOMETRY : String = "geometry" ;
		public static const PREFIX_MATERIAL : String = "material" ;
		
		protected var mainSections : Array = [ ] ;
		protected var geometry : Array = [ ] ;
		protected var cameras : Array = [ ] ;
		protected var allSections : Array = [ ] ;
		
		
		
		public function ColladaParser ( )
		{
			super ( ) ;
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Public Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		override public function parse ( data : * ) : void
		{
			var xml : XML = data as XML ;
			
			this.extractMainSections ( xml ) ;
			this._sections = this.mainSections ;
			this.dispatchEvent ( new Event ( Event.COMPLETE ) ) ;
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Protected Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		protected function extractMainSections ( xml : XML ) : void
		{
			var list : XMLList = xml[ ColladaNode.LIBRARY_VISUAL_SCENES ][ ColladaNode.VISUAL_SCENE ].node as XMLList ;
			
			for each ( var node : XML in list )
			{
				var children : XMLList = node.children ( ) ;
				var vo : SceneSectionVO = new SceneSectionVO ( ) ;
				
				vo.id = node.@id ;
				vo.name = node.@name ;
				vo.values = this.extractPivot ( node ) ;
				vo.cameras = this.extractGroup ( ColladaParser.GROUP_CAMERA , vo , children ) ;
				vo.geometry = this.extractGroup ( ColladaParser.GROUP_GEOMETRY , vo , children ) ;
				vo.sections = this.extractGroup ( ColladaParser.GROUP_SECTION , vo , children ) ;
				this.mainSections.push ( vo ) ;
				this.sections.push ( vo ) ;
			}
		}
		
		
		
		protected function extractPivot ( xml : XML ) : SceneObjectVO
		{
			var positions : Array = this.extractValues ( ColladaNode.VALUE_TYPE_POSITION , xml[ ColladaNode.TRANSLATE ] ) ;
			var rotations : Array = this.extractValues ( ColladaNode.VALUE_TYPE_ROTATION , xml[ ColladaNode.ROTATE ] ) ;
			var scales : Array = this.extractValues ( ColladaNode.VALUE_TYPE_SCALE , xml[ ColladaNode.SCALE ] ) ;
			var pivot : SceneObjectVO = new SceneObjectVO ( ) ;
			
			this.applyPosition ( pivot , positions ) ;
			this.applyRotation ( pivot , rotations ) ;
			this.applyScale ( pivot , scales ) ;
			return pivot ;
		}
		
		
		
		protected function extractGroup ( group : uint , section : SceneSectionVO , list : XMLList ) : Array
		{
			var a : Array = new Array ( ) ;
			var counter : uint = 0 ;
			
			for each ( var node : XML in list )
			{
				var type : String = node.@type ;
				
				if ( type == ColladaParser.GROUP_IDENTIFIER && counter == group )
				{
					switch ( group )
					{
						case ColladaParser.GROUP_CAMERA :
						{
							a = this.extractCameras ( /*section ,*/ node.children ( ) ) ;
							break ;
						}
						case ColladaParser.GROUP_GEOMETRY :
						{
							a = this.extractGeometry ( section , node.children ( ) ) ;
							break ;
						}	
						case ColladaParser.GROUP_SECTION :
						{
							a = this.extractSection ( /*section ,*/ node ) ;
							break ;
						}
					}
				}
				
				if ( type == ColladaParser.GROUP_IDENTIFIER ) counter ++ ;
			}
			
			return a ;
		}
		
		
		
		protected function extractSection ( /*section : SceneSectionVO ,*/ xml : XML ) : Array
		{
			var a : Array = new Array ( ) ;
			
			for each ( var node : XML in xml[ ColladaNode.NODE ] )
			{
				var vo : SceneSectionVO = new SceneSectionVO ( ) ;
				var children : XMLList = node.children ( ) ;
				
				vo.id = node.@id ;
				vo.name = node.@name ;
				vo.values = this.extractPivot ( xml ) ;
				//vo.pivot = section.pivot ;
				vo.cameras = this.extractGroup ( ColladaParser.GROUP_CAMERA , vo , children ) ;
				vo.geometry = this.extractGroup ( ColladaParser.GROUP_GEOMETRY , vo , children ) ;
				vo.sections = this.extractGroup ( ColladaParser.GROUP_SECTION , vo , children ) ;
				a.push ( vo ) ;
				this.allSections.push ( vo ) ;
			}
			
			return a ;
		}
		
		
		
		protected function extractCameras ( /*section : SceneSectionVO ,*/ list : XMLList ) : Array
		{
			var cameras : Array = new Array ( ) ;
			
			for each ( var node : XML in list )
			{
				var type : String = node.@type ;
				
				if ( type == ColladaParser.GROUP_IDENTIFIER )
				{
					var vo : SceneCameraVO = new SceneCameraVO ( ) ;
					var values : SceneObjectVO = new SceneObjectVO ( ) ;
					var children : XMLList = node.children ( ) ;
					var positions : Array = this.extractValues ( ColladaNode.VALUE_TYPE_POSITION , children ) ;
					var rotations : Array = this.extractValues ( ColladaNode.VALUE_TYPE_ROTATION , children ) ;
					var extras : XMLList = ( node[ ColladaNode.EXTRA ][ ColladaNode.TECHNIQUE ][ ColladaNode.DYNAMIC_ATTRIBUTES ] as XMLList ).children ( ) ;
					
					this.applyPosition ( values , positions ) ;
					this.applyRotation ( values , rotations ) ;
					vo.id = node.@id ;
					vo.name = node.@name ;
					//vo.parentSection = section ;
					vo.values = values ;
					if ( extras.toString ( ) != "" ) vo = this.extractCameraExtras ( vo , extras ) ;
					cameras.push ( vo ) ;
					this.cameras.push ( vo ) ;
				}
			}
			
			return cameras ;
		}
		
		
		
		protected function extractCameraExtras ( vo : SceneCameraVO , extras : XMLList ) : SceneCameraVO
		{
			for each ( var node : XML in extras )
			{
				var attribute : DynamicAttributeVO = new DynamicAttributeVO ( ) ;
				var name : String = ( node.name ( ) ).toString ( ) ;
				var pair : Array = name.split ( "_" ) ;
				var prefix : String = pair[ 0 ] ;
				var key : String = pair[ 1 ] ;
				var value : String = node.toString ( ) ;
				
				attribute.key = key ;
				attribute.value = value ;
				
				switch ( prefix )
				{
					case ColladaParser.PREFIX_CAMERA :
					{
						vo.extras.push ( attribute ) ;
						break ;
					}
				}
			}
			
			return vo ;
		}
		
		
		
		protected function extractGeometry ( section : SceneSectionVO , list : XMLList ) : Array
		{
			var geometry : Array = new Array ( ) ;
			
			for each ( var node : XML in list )
			{
				var type : String = node.@type ;
				
				if ( type == ColladaParser.GROUP_IDENTIFIER )
				{
					var vo : SceneGeometryVO = new SceneGeometryVO ( ) ;
					var values : SceneObjectVO = new SceneObjectVO ( ) ;
					var children : XMLList = node.children ( ) ;
					var positions : Array = this.extractValues ( ColladaNode.VALUE_TYPE_POSITION , children ) ;
					var rotations : Array = this.extractValues ( ColladaNode.VALUE_TYPE_ROTATION , children ) ;
					var scales : Array = this.extractValues ( ColladaNode.VALUE_TYPE_SCALE , children ) ;
					var extras : XMLList = ( node[ ColladaNode.EXTRA ][ ColladaNode.TECHNIQUE ][ ColladaNode.DYNAMIC_ATTRIBUTES ] as XMLList ).children ( ) ;
					
					this.applyPosition ( values , positions ) ;
					this.applyRotation ( values , rotations ) ;
					this.applyScale ( values , scales ) ;
					vo.id = node.@id ;
					vo.name = node.@name ;
					vo.values = values ;
					vo.enabled = section.enabled ;
					if ( extras.toString ( ) != "" ) vo = this.extractGeometryExtras ( vo , extras ) ;
					geometry.push ( vo ) ;
					this.geometry.push ( vo ) ;
				}
			}
			
			return geometry ;
		}
		
		
		
		protected function extractGeometryExtras ( vo : SceneGeometryVO , extras : XMLList ) : SceneGeometryVO
		{
			for each ( var node : XML in extras )
			{
				var attribute : DynamicAttributeVO = new DynamicAttributeVO ( ) ;
				var name : String = ( node.name ( ) ).toString ( ) ;
				var pair : Array = name.split ( "_" ) ;
				var prefix : String = pair[ 0 ] ;
				var key : String = pair[ 1 ] ;
				var value : String = node.toString ( ) ;
				
				attribute.key = key ;
				attribute.value = value ;
				
				switch ( prefix )
				{
					case ColladaParser.PREFIX_GEOMETRY :
					{
						vo.geometryExtras.push ( attribute ) ;
						break ;
					}
					case ColladaParser.PREFIX_MATERIAL :
					{
						switch ( attribute.key )
						{
							case MaterialAttributes.ASSET_CLASS :
							{
								var result : Array = [ attribute.value , vo.id ] ;
								
								this.expectedMaterialClasses.push ( result ) ;
								break ;
							}
						}
						
						vo.materialExtras.push ( attribute ) ;
						break ;
					}
				}
			}
			
			return vo ;
		}
		
		
		
		protected function extractValues ( type : String , list : XMLList ) : Array
		{
			var sList : String = list.toString ( ) ;
			var positions : Array = new Array ( 0 , 0 , 0 ) ;
			var rotations : Array = new Array ( 0 , 0 , 0 ) ;
			var scales : Array = new Array ( 1 , 1 , 1 ) ;
			var values : Array ;
			
			if ( sList != "" )
			{
				for each ( var node : XML in list )
				{
					var sNode : String = node.toString ( ) ;
					var sid : String = node.@sid ;
					
					switch ( sid )
					{
						case ColladaNode.TRANSLATE :
						{
							positions = sNode.split ( " " ) ;
							break ;
						}	
						case ColladaNode.ROTATE_X :
						{
							rotations[ 0 ] = this.extractLastEntry ( sNode ) ;
							break ;
						}	
						case ColladaNode.ROTATE_Y :
						{
							rotations[ 1 ] = this.extractLastEntry ( sNode ) ;
							break ;
						}	
						case ColladaNode.ROTATE_Z :
						{
							rotations[ 2 ] = this.extractLastEntry ( sNode ) ;
							break ;
						}	
						case ColladaNode.SCALE :
						{
							scales = sNode.split ( " " ) ;
							break ;
						}	
					}
				}
			}
			
			switch ( type )
			{
				case ColladaNode.VALUE_TYPE_POSITION :
				{
					values = positions ;
					break ;
				}	
				case ColladaNode.VALUE_TYPE_ROTATION :
				{
					values = rotations ;
					break ;
				}	
				case ColladaNode.VALUE_TYPE_SCALE :
				{
					values = scales ;
					break ;
				}	
			}
			
			return values ;
		}
		
		
		
		protected function extractLastEntry ( sNode : String ) : Number
		{
			var values : Array = sNode.split ( " " ) ;
			var last : Number = values[ values.length - 1 ] ;
			
			return last ;
		}
		
		
		
		protected function applyPosition ( target : SceneObjectVO , values : Array ) : void
		{
			target.x = values[ 0 ] ;
			target.y = values[ 1 ] ;
			target.z = values[ 2 ] ;
		}
		
		
		
		protected function applyRotation ( target : SceneObjectVO , values : Array ) : void
		{
			target.rotationX = values[ 0 ] ;
			target.rotationY = values[ 1 ] ;
			target.rotationZ = values[ 2 ] ;
		}
		
		
		
		protected function applyScale ( target : SceneObjectVO , values : Array ) : void
		{
			target.scaleX = values[ 0 ] ;
			target.scaleY = values[ 1 ] ;
			target.scaleZ = values[ 2 ] ;
		}
	}
}