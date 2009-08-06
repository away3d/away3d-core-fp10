package awaybuilder.utils
{
	import awaybuilder.CoordinateSystem;
	
	
	
	public class ConvertCoordinates
	{
		public static function radToDeg ( value : Number ) : Number
		{
			return value * ( 180 / Math.PI ) ;
		}
		
		
		
		public static function groupPositionX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function groupPositionY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function groupPositionZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function positionX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function positionY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				{
					return -n ;
				}
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function positionZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function scale ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				{
					return n / 100 ;
				}
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function groupRotationX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function groupRotationY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function groupRotationZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function meshRotationX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function meshRotationY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.CINEMA4D :
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function meshRotationZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.CINEMA4D :
				{
					return n * -1 ;
				}
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function colladaRotationX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function colladaRotationY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.CINEMA4D :
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function colladaRotationZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.CINEMA4D :
				{
					return n * -1 ;
				}
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function cameraPositionX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function cameraPositionY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function cameraPositionZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function cameraRotationX ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function cameraRotationY ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.CINEMA4D :
				case CoordinateSystem.MAYA :
				{
					return n * -1 ;
				}
				default :
				{
					return n ;
				}
			}
		}
		
		
		
		public static function cameraRotationZ ( n : Number , coordinateSystem : String ) : Number
		{
			switch ( coordinateSystem )
			{
				case CoordinateSystem.AFTER_EFFECTS :
				case CoordinateSystem.CINEMA4D :
				{
					return n * -1 ;
				}
				default :
				{
					return n ;
				}
			}
		}
	}
}