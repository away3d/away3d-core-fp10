package awaybuilder.material
{
	import away3d.materials.PhongColorMaterial;	
	import away3d.materials.ColorMaterial;
	import away3d.materials.ShadingColorMaterial;
	import away3d.materials.VideoMaterial;
	import away3d.materials.WireColorMaterial;
	import away3d.materials.WireframeMaterial;
	
	import awaybuilder.vo.DynamicAttributeVO;
	import awaybuilder.vo.SceneGeometryVO;
	
	
	
	public class MaterialFactory
	{
		protected var propertyFactory : MaterialPropertyFactory ;
		
		
		
		public function MaterialFactory ( )
		{
			this.propertyFactory = new MaterialPropertyFactory ( ) ;
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Public Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		public function build ( attribute : DynamicAttributeVO , vo : SceneGeometryVO ) : SceneGeometryVO
		{
			switch ( attribute.value )
			{
				/*
				NOTE: Creation of materials that require external data happens
				at the end of the geometry creation process. See SceneBuilder.
				
				case MaterialType.BITMAP_MATERIAL :
				case MaterialType.BITMAP_FILE_MATERIAL :
				case MaterialType.MOVIE_MATERIAL :
				case MaterialType.PHONG_BITMAP_MATERIAL :
				*/
				
				case MaterialType.COLOR_MATERIAL :
				{
					vo.material = new ColorMaterial ( ) ;
					break ;
				}
				case MaterialType.PHONG_COLOR_MATERIAL :
				{
					vo.material = new PhongColorMaterial ( 0x00FF00 ) ;
					break ;
				}
				case MaterialType.SHADING_COLOR_MATERIAL :
				{
					vo.material = new ShadingColorMaterial ( ) ;
					break ;
				}
				case MaterialType.VIDEO_MATERIAL :
				{
					vo.material = new VideoMaterial ( ) ;
					break ;
				}
				case MaterialType.WIRE_COLOR_MATERIAL :
				{
					vo.material = new WireColorMaterial ( ) ;
					break ;
				}
				case MaterialType.WIREFRAME_MATERIAL :
				{
					vo.material = new WireframeMaterial ( ) ;
					break ;
				}
				default :
				{
					// TODO: Confirm that this behaviour works correctly
					vo = this.buildDefault ( vo ) ;
				}
			}
			
			vo = this.propertyFactory.build ( vo ) ;
			vo.materialType = attribute.value ;
			
			return vo ;
		}
		
		
		
		public function buildDefault ( vo : SceneGeometryVO ) : SceneGeometryVO
		{
			var wireColorMaterial : WireColorMaterial = new WireColorMaterial ( ) ;
			
			wireColorMaterial.color = 0x00FF00 ;
			vo.material = wireColorMaterial ;
			vo.materialType = MaterialType.WIRE_COLOR_MATERIAL ;
			
			return vo ;
		}
	}
}