package away3d.primitives 
{

	/**
	 * Static class that provides constant values for the UV mapping options of the <code>Cube</code> primitive.
	 */
	public class CubeMappingType 
	{
		/**
		 * Applies a Pano2VR-style mapping that subdivides the texture into 6 separate areas, one for each side of the cube.
		 */
		public static var MAP6:String = "map6";
		
		/**
		 * Applies a representation of the whole texture to each side of the cube.
		 */
		public static var NORMAL:String = "normal";
	}
}
