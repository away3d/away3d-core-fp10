package away3d.sprites
{
	import away3d.materials.*;
	
	/**
	 * Spherical billboard (always facing the camera) sprite object that uses a cached array of bitmapData objects as it's texture.
	 * A depth of field blur image over a number of different perspecives is drawn and cached for later retrieval and display.
	 */
	public class DepthOfFieldSprite extends Sprite3D
    {
		/**
		 * Creates a new <code>DepthOfFieldSprite</code> object.
		 * 
		 */
        public function DepthOfFieldSprite(material:Material = null, width:Number = 10, height:Number = 10, rotation:Number = 0, align:String = "center", scaling:Number = 1, distanceScaling:Boolean = true)
        {
			super(material, width, height, rotation, align, scaling, distanceScaling);
			
			spriteVO.depthOfField = true;
        }
    }
}