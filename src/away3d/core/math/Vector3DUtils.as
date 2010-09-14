package away3d.core.math
{
	import flash.geom.*;
	
	/**
	 * @author robbateman
	 */
	public class Vector3DUtils
	{
		
    	/**
    	 * Returns the angle in radians made between the 3d number obejct and the given 3d number.
    	 * 
    	 * @param	w				The first 3d number object to use in the calculation.
    	 * @param	q				The first 3d number object to use in the calculation.
    	 * @return					An angle in radians representing the angle between the two <code>Vector3D</code> objects. 
    	 */
        public static function getAngle(w:Vector3D, q:Vector3D):Number
        {
            return Math.acos(w.dotProduct(q)/(w.length*q.length));
        }
	}
}
