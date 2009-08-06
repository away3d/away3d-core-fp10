package awaybuilder.parsers
{
	import awaybuilder.abstracts.AbstractParser;
	import awaybuilder.geometry.GeometryAttributes;
	import awaybuilder.material.MaterialAttributes;
	import awaybuilder.vo.DynamicAttributeVO;
	import awaybuilder.vo.GroupVO;
	import awaybuilder.vo.MaterialVO;
	import awaybuilder.vo.SceneCameraVO;
	import awaybuilder.vo.SceneGeometryVO;
	import awaybuilder.vo.SceneObjectVO;
	import awaybuilder.vo.SceneSectionVO;
	
	import flash.events.Event;
	
	
	
	public class SceneXMLParser extends AbstractParser
	{
		protected static const NODE_CAMERAS : String = "cameras" ;
		protected static const NODE_GEOMETRY : String = "geometry" ;
		protected static const NODE_GROUP : String = "group" ;
		protected static const NODE_GROUPS : String = "groups" ;
		protected static const NODE_MATERIAL : String = "material" ;
		protected static const NODE_MATERIALS : String = "materials" ;
		protected static const NODE_POSITION : String = "position" ;
		protected static const NODE_PROPERTIES : String = "properties" ;
		protected static const NODE_ROTATION : String = "rotation" ;
		protected static const NODE_SCALE : String = "scale" ;
		protected static const NODE_SECTION : String = "section" ;
		protected static const NODE_SECTIONS : String = "sections" ;
		
		protected var groups : Array = [ ] ;
		protected var materials : Array = [ ] ;
		
		
		
		public function SceneXMLParser ( )
		{
			super ;
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		//	Override Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		override public function parse ( data : * ) : void
		{
			var xml : XML = new XML ( data ) ;
			
			this.parseGroups ( xml[ NODE_GROUPS ][ NODE_GROUP ] ) ;
			this.parseMaterials ( xml[ NODE_MATERIALS ] ) ;
			this.parseSections ( xml[ NODE_SECTIONS ][ NODE_SECTION ] ) ;
			this.dispatchEvent ( new Event ( Event.COMPLETE ) ) ;
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		//	Protected Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		protected function parseGroups ( list : XMLList ) : void
		{
			for each ( var item : XML in list )
			{
				var vo : GroupVO = new GroupVO ( ) ;
				
				vo.id = item.@id ;
				
				for each ( var property : XML in item.children ( ) )
				{
					this.pushProperty ( property , vo.properties ) ;
				}
				
				this.groups.push ( vo ) ;
			}
		}
		
		
		
		protected function pushProperty ( property : XML , properties : Array ) : void
		{
			var attribute : DynamicAttributeVO = new DynamicAttributeVO ( ) ;
			
			attribute.key = property.name ( ).toString ( ) ;
			attribute.value = property ;
			properties.push ( attribute ) ;
		}
		
		
		
		protected function parseMaterials ( list : XMLList ) : void
		{
			for each ( var material : XML in list.children ( ) )
			{
				var vo : MaterialVO = new MaterialVO ( ) ;
				var type : DynamicAttributeVO = new DynamicAttributeVO ( ) ;
				
				vo.id = material.@id ;
				vo.name = material.name ( ).toString ( ) ;
				type.key = MaterialAttributes.CLASS ;
				type.value = material.name ( ).toString ( ) ;
				vo.properties.push ( type ) ;
				
				for each ( var property : XML in material.children ( ) )
				{
					if ( property.name ( ).toString ( ) == NODE_GROUP )
					{
						this.applyGroupProperties ( property.@id , vo.properties ) ;
					}
					else
					{
						this.pushProperty ( property , vo.properties ) ;
					}
				}
				
				this.materials.push ( vo ) ;
			}
		}
		
		
		
		protected function applyGroupProperties ( groupId : String , properties : Array ) : void
		{
			var group : GroupVO = this.getGroupById ( groupId ) ;
			
			for each ( var attribute : DynamicAttributeVO in group.properties )
			{
				properties.push ( attribute ) ;
			}
		}
		
		
		
		protected function getGroupById ( id : String ) : GroupVO
		{
			for each ( var vo : GroupVO in this.groups )
			{
				if ( vo.id == id ) return vo ;
			}
			
			throw new Error ( "group with id [" + id + "] not found" ) ;
		}
		
		
		
		protected function parseSections ( list : XMLList ) : void
		{
			for each ( var item : XML in list )
			{
				var vo : SceneSectionVO = new SceneSectionVO ( ) ;
				
				this.extractValues ( item , vo.values ) ;
				
				for each ( var child : XML in item.children ( ) )
				{
					switch ( child.name ( ).toString ( ) )
					{
						case NODE_CAMERAS :
						{
							this.parseCameras ( child.children ( ) , vo ) ;
							break ;
						}
						case NODE_GEOMETRY :
						{
							this.parseGeometry ( child.children ( ) , vo ) ;
							break ;
						}
					}
				}
				
				this._sections.push ( vo ) ;
			}
		}
		
		
		
		protected function extractValues ( item : XML , values : SceneObjectVO ) : void
		{
			for each ( var child : XML in item.children ( ) )
			{
				switch ( child.name ( ).toString ( ) )
				{
					case NODE_POSITION :
					{
						values.x = child.@x ;
						values.y = child.@y ;
						values.z = child.@z ;
						break ;
					}
					case NODE_ROTATION :
					{
						values.rotationX = child.@x ;
						values.rotationY = child.@y ;
						values.rotationZ = child.@z ;
						break ;
					}
					case NODE_SCALE :
					{
						values.scaleX = child.@x ;
						values.scaleY = child.@y ;
						values.scaleZ = child.@z ;
						break ;
					}
				}
			}
		}
		
		
		
		protected function parseCameras ( list : XMLList , section : SceneSectionVO ) : void
		{
			for each ( var item : XML in list )
			{
				var vo : SceneCameraVO = new SceneCameraVO ( ) ;
				
				vo.id = item.@id ;
				this.extractValues ( item , vo.values ) ;
				
				for each ( var child : XML in item.children ( ) )
				{
					switch ( child.name ( ).toString ( ) )
					{
						case NODE_PROPERTIES :
						{
							for each ( var property : XML in child.children ( ) )
							{
								if ( property.name ( ).toString ( ) == NODE_GROUP )
								{
									this.applyGroupProperties ( property.@id , vo.extras ) ;
								}
								else
								{
									this.pushProperty ( property , vo.extras ) ;
								}
							}
							
							break ;
						}
					}
				}
				
				section.cameras.push ( vo ) ;
			}
		}
		
		
		
		protected function parseGeometry ( list : XMLList , section : SceneSectionVO ) : void
		{
			for each ( var item : XML in list )
			{
				var vo : SceneGeometryVO = new SceneGeometryVO ( ) ;
				var type : DynamicAttributeVO = new DynamicAttributeVO ( ) ;
				
				vo.id = item.@id ;
				type.key = GeometryAttributes.CLASS ;
				type.value = item.name ( ).toString ( ) ;
				vo.geometryExtras.push ( type ) ;
				this.extractValues ( item , vo.values ) ;
				
				for each ( var child : XML in item.children ( ) )
				{
					switch ( child.name ( ).toString ( ) )
					{
						case NODE_PROPERTIES :
						{
							for each ( var property : XML in child.children ( ) )
							{
								switch ( property.name ( ).toString ( ) )
								{
									case NODE_GROUP :
									{
										this.applyGroupProperties ( property.@id , vo.geometryExtras ) ;
										break ;
									}
									case NODE_MATERIAL :
									{
										this.applyMaterialProperties ( property.@id , vo.materialExtras ) ;
										break ;
									}
									default :
									{
										this.pushProperty ( property , vo.geometryExtras ) ;
										break ;
									}
								}
							}
							
							break ;
						}
					}
				}
				
				section.geometry.push ( vo ) ;
			}
		}
		
		
		
		protected function applyMaterialProperties ( materialId : String , properties : Array ) : void
		{
			var material : MaterialVO = this.getMaterialById ( materialId ) ;
			
			for each ( var attribute : DynamicAttributeVO in material.properties )
			{
				properties.push ( attribute ) ;
			}
		}
		
		
		
		protected function getMaterialById ( id : String ) : MaterialVO
		{
			for each ( var vo : MaterialVO in this.materials )
			{
				if ( vo.id == id ) return vo ;
			}
			
			throw new Error ( "material with id [" + id + "] not found" ) ;
		}
	}
}