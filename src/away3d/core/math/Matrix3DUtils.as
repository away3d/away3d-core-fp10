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
        
        /**
        * Returns a normalised <code>Vector3D</code> object representing the forward vector of the given matrix.
        */
        public static function getForward(m:Matrix3D):Vector3D
        {
        	var result:Vector3D = new Vector3D(m.rawData[uint(8)], m.rawData[uint(9)], m.rawData[uint(10)]);
        	result.normalize();
        	return result;
        }
     	
     	/**
        * Returns a normalised <code>Vector3D</code> object representing the up vector of the given matrix.
        */
        public static function getUp(m:Matrix3D):Vector3D
        {
        	var result:Vector3D = new Vector3D(m.rawData[uint(4)], m.rawData[uint(5)], m.rawData[uint(6)]);
        	result.normalize();
        	return result;
        }
     	
     	/**
        * Returns a normalised <code>Vector3D</code> object representing the right vector of the given matrix.
        */
        public static function getRight(m:Matrix3D):Vector3D
        {
        	var result:Vector3D = new Vector3D(m.rawData[uint(0)], m.rawData[uint(1)], m.rawData[uint(2)]);
        	result.normalize();
        	return result;
        }
     	
     	/**
        * Returns a boolean value representing whether there is any significant difference between the two given 3d matrices.
        */
        public static function compare(m1:Matrix3D, m2:Matrix3D):Boolean
        {
        	return m1.rawData.toString() == m2.rawData.toString();
        }
        
	}
}
