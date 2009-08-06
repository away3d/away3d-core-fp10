package awaybuilder.material
{
	import awaybuilder.utils.ConvertType;
	import awaybuilder.vo.DynamicAttributeVO;
	import awaybuilder.vo.SceneGeometryVO;
	
	
	
	public class MaterialPropertyFactory
	{
		public function MaterialPropertyFactory ( )
		{
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Public Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		public function build ( vo : SceneGeometryVO ) : SceneGeometryVO
		{
			for each ( var attribute : DynamicAttributeVO in vo.materialExtras )
			{
				switch ( attribute.key )
				{
					case MaterialAttributes.ALPHA :
					case MaterialAttributes.AMBIENT :
					case MaterialAttributes.COLOR :
					case MaterialAttributes.DIFFUSE :
					case MaterialAttributes.PAN :
					case MaterialAttributes.SHININESS :
					case MaterialAttributes.SPECULAR :
					case MaterialAttributes.VOLUME :
					case MaterialAttributes.WIDTH :
					case MaterialAttributes.WIREALPHA :
					case MaterialAttributes.WIRECOLOR :
					{
						vo.material[ attribute.key ] = Number ( attribute.value ) ;
						break ;
					}
					case MaterialAttributes.ASSET_CLASS :
					case MaterialAttributes.ASSET_FILE :
					case MaterialAttributes.ASSET_FILE_BACK :
					{
						vo[ attribute.key ] = attribute.value ;
						break ;
					}
					case MaterialAttributes.AUTO_UPDATE :
					case MaterialAttributes.INTERACTIVE :
					case MaterialAttributes.SMOOTH :
					case MaterialAttributes.TRANSPARENT :
					{
						vo[ attribute.key ] = ConvertType.convertToBoolean ( attribute.value ) ;
						break ;
					}
					case MaterialAttributes.LOCK_H :
					case MaterialAttributes.LOCK_W :
					case MaterialAttributes.PRECISION :
					{
						vo[ attribute.key ] = Number ( attribute.value ) ;
						break ;
					}
					case MaterialAttributes.FILE :
					case MaterialAttributes.RTMP :
					{
						vo.material[ attribute.key ] = attribute.value ;
						break ;
					}
					case MaterialAttributes.LOOP :
					{
						vo.material[ attribute.key ] = ConvertType.convertToBoolean ( attribute.value ) ;
						break ;
					}
				}
			}
			
			return vo ;
		}
	}
}