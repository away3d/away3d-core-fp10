package awaybuilder.geometry
{
	import awaybuilder.utils.ConvertType;
	import awaybuilder.vo.DynamicAttributeVO;
	import awaybuilder.vo.SceneGeometryVO;
	
	
	
	public class GeometryPropertyFactory
	{
		public var precision : uint ;
		
		
		
		public function GeometryPropertyFactory ( )
		{
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		//	Public Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		public function build ( vo : SceneGeometryVO ) : SceneGeometryVO
		{
			for each ( var attribute : DynamicAttributeVO in vo.geometryExtras )
			{
				switch ( attribute.key )
				{
					case GeometryAttributes.ASSET_CLASS :
					case GeometryAttributes.ASSET_FILE :
					case GeometryAttributes.ASSET_FILE_BACK :
					case GeometryAttributes.TARGET_CAMERA :
					{
						vo[ attribute.key ] = attribute.value ;
						break ;
					}
					case GeometryAttributes.BOTHSIDES :
					case GeometryAttributes.OWN_CANVAS :
					case GeometryAttributes.PUSHBACK :
					case GeometryAttributes.PUSHFRONT :
					case GeometryAttributes.Y_UP :
					{
						vo.mesh[ attribute.key ] = ConvertType.convertToBoolean ( attribute.value ) ;
						break ;
					}
					case GeometryAttributes.COLLADA_SCALE :
					{
						vo[ attribute.key ] = Number ( attribute.value ) ;
						break ;
					}
					case GeometryAttributes.DEPTH :
					case GeometryAttributes.HEIGHT :
					case GeometryAttributes.RADIUS :
					case GeometryAttributes.TUBE :
					case GeometryAttributes.WIDTH :
					{
						vo.mesh[ attribute.key ] = this.precision * Number ( attribute.value ) ;
						break ;
					}
					case GeometryAttributes.ENABLED :
					case GeometryAttributes.FLIP_TEXTURE :
					case GeometryAttributes.MOUSE_DOWN_ENABLED :
					case GeometryAttributes.MOUSE_MOVE_ENABLED :
					case GeometryAttributes.MOUSE_OUT_ENABLED :
					case GeometryAttributes.MOUSE_OVER_ENABLED :
					case GeometryAttributes.MOUSE_UP_ENABLED :
					case GeometryAttributes.SMOOTH_TEXTURE :
					case GeometryAttributes.USE_HAND_CURSOR :
					{
						vo[ attribute.key ] = ConvertType.convertToBoolean ( attribute.value ) ;
						break ;
					}
					case GeometryAttributes.SEGMENTS_W :
					case GeometryAttributes.SEGMENTS_H :
					case GeometryAttributes.SEGMENTS_R :
					case GeometryAttributes.SEGMENTS_T :
					{
						vo.mesh[ attribute.key ] = uint ( attribute.value ) ;
						break ;
					}
				}
			}
			
			return vo ;
		}
	}
}