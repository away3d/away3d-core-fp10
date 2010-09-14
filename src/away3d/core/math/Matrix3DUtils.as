package away3d.core.math
{
	import flash.geom.*;
	
	/**
	 * @author robbateman
	 */
	public class Matrix3DUtils
	{
        /**
        * Fills the 3d matrix object with values representing the transformation made by the given quaternion.
        * 
        * @param	quarternion	The quarterion object to convert.
        */
        public static function quaternion2matrix(quarternion:Quaternion):Matrix3D
        {
        	var x:Number = quarternion.x;
        	var y:Number = quarternion.y;
        	var z:Number = quarternion.z;
        	var w:Number = quarternion.w;
        	
            var xx:Number = x * x;
            var xy:Number = x * y;
            var xz:Number = x * z;
            var xw:Number = x * w;
    
            var yy:Number = y * y;
            var yz:Number = y * z;
            var yw:Number = y * w;
    
            var zz:Number = z * z;
            var zw:Number = z * w;
            
            return new Matrix3D(Vector.<Number>([1 - 2 * (yy + zz), 2 * (xy + zw), 2 * (xz - yw), 0, 2 * (xy - zw), 1 - 2 * (xx + zz), 2 * (yz + xw), 0, 2 * (xz + yw), 2 * (yz - xw), 1 - 2 * (xx + yy), 0, 0, 0, 0, 1]));
        }
	}
}
