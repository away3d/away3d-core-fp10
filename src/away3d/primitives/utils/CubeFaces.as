package away3d.primitives.utils
{
	/**
	 * The names of the cube map faces used in CubicEnvMapPBMaterial, to determine the positions of each side's texture
	 */
	public class CubeFaces
	{
		/**
		 * The face on the left hand side
		 */
		public static const LEFT : String = "left";
		
		/**
		 * The face on the right hand side
		 */
		public static const RIGHT : String = "right";
		
		/**
		 * The face on the top of the cube
		 */
		public static const TOP : String = "top";
		
		/**
		 * The face on the bottom of the cube, ie. the "floor"
		 */
		public static const BOTTOM : String = "bottom";
		
		/**
		 * The face on the back side of the cube.
		 */
		public static const BACK : String = "back";
		
		/**
		 * The face on the front side of the cube.
		 */
		public static const FRONT : String = "front";
	}
}