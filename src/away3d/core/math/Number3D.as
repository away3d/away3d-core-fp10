package away3d.core.math
{
    import flash.geom.*;
    
    /**
    * A point in 3D space.
    */
    public final class Number3D extends Vector3D
    {
    	private const MathPI:Number = Math.PI;
        private var dist:Number;
        private var num:Vector3D;
        private var vx:Number;
        private var vy:Number;
        private var vz:Number;
    	
    	/**
    	 * The modulo of the 3d number object.
    	 */
        public function get modulo():Number
        {
            return Math.sqrt(x*x + y*y + z*z);
        }
    	
    	/**
    	 * The squared modulo of the 3d number object.
    	 */
        public function get modulo2():Number
        {
            return x*x + y*y + z*z;
        }
        
		/**
		 * Creates a new <code>Vector3D</code> object.
		 *
		 * @param	x	[optional]	A default value for the horizontal coordinate of the 3d number object. Defaults to 0.
		 * @param	y	[optional]	A default value for the vertical coordinate of the 3d number object. Defaults to 0.
		 * @param	z	[optional]	A default value for the depth coordinate of the 3d number object. Defaults to 0.
		 * @param	n	[optional]	Determines of the resulting 3d number object should be normalised. Defaults to false.
		 */
        public function Number3D(x:Number = 0, y:Number = 0, z:Number = 0, n:Boolean = false)
        {
            this.x = x;
            this.y = y;
            this.z = z;
            
            if (n)
            	normalize();
        }
    	
    	/**
    	 * Calculates the distance from the 3d number object to the given 3d number.
    	 * 
    	 * @param	w	The 3d number object whose distance is calculated.
    	 */
        public function distance(w:Vector3D):Number
        {
            return Math.sqrt((x - w.x)*(x - w.x) + (y - w.y)*(y - w.y) + (z - w.z)*(z - w.z));
        }
    	
    	/**
    	 * Calculates the dot product of the 3d number object with the given 3d number.
    	 * 
    	 * @param	w	The 3d number object to use in the calculation.
    	 * @return		The dot product result.
    	 */
        public function dot(w:Vector3D):Number
        {
            return (x * w.x + y * w.y + z * w.z);
        }
		
    	/**
    	 * Fills the 3d number object with the result from an cross product of two 3d numbers.
    	 * 
    	 * @param	v	The first 3d number in the cross product calculation.
    	 * @param	w	The second 3d number in the cross product calculation.
    	 */
        public function cross(v:Vector3D, w:Vector3D):void
        {
        	if (this == v || this == w)
        		throw new Error("resultant cross product cannot be the same instance as an input");
        	x = w.y * v.z - w.z * v.y;
        	y = w.z * v.x - w.x * v.z;
        	z = w.x * v.y - w.y * v.x;
        }
    	
    	/**
    	 * Returns the angle in radians made between the 3d number obejct and the given 3d number.
    	 * 
    	 * @param	w	[optional]	The 3d number object to use in the calculation.
    	 * @return					An angle in radians representing the angle between the two 3d number objects. 
    	 */
        public function getAngle(w:Vector3D = null):Number
        {
            if (w == null)
            	w = new Vector3D();
            return Math.acos(dot(w)/(modulo*w.length));
        }
        
    	/**
    	 * Fills the 3d number object with the result of a 3d matrix rotation performed on a 3d number.
    	 * 
    	 * @param	v	The 3d number object to use in the calculation.
    	 * @param	m	The 3d matrix object representing the rotation.
    	 */
        public function rotate(v:Number3D, m:Matrix3D):void
        {
        	vx = v.x;
        	vy = v.y;
        	vz = v.z;
        	
            x = vx * m.rawData[0] + vy * m.rawData[4] + vz * m.rawData[8];
            y = vx * m.rawData[1] + vy * m.rawData[5] + vz * m.rawData[9];
            z = vx * m.rawData[2] + vy * m.rawData[6] + vz * m.rawData[10];
        }
    	
    	/**
    	 * Fills the 3d number object with the result of a 3d matrix tranformation performed on a 3d number.
    	 * 
    	 * @param	v	The 3d number object to use in the calculation.
    	 * @param	m	The 3d matrix object representing the tranformation.
    	 */
        public function transform(v:Number3D, m:Matrix3D):void
        {
        	vx = v.x;
        	vy = v.y;
        	vz = v.z;
        	
            x = vx * m.rawData[0] + vy * m.rawData[4] + vz * m.rawData[8] + m.rawData[12];
            y = vx * m.rawData[1] + vy * m.rawData[5] + vz * m.rawData[9] + m.rawData[13];
            z = vx * m.rawData[2] + vy * m.rawData[6] + vz * m.rawData[10] + m.rawData[14];
        }
            	
    	/**
    	 * Fill the 3d number object with the euler angles represented by the 3x3 matrix rotation.
    	 * 
    	 * @param	m	The 3d matrix object to use in the calculation.
    	 */
		public function matrix2euler(m1:Matrix3D):void
        {
            var m2:Matrix3D = new Matrix3D();
            
		    // Extract the first angle, rotationX
			x = -Math.atan2(m1.rawData[6], m1.rawData[10]); // rot.x = Math<T>::atan2 (M[1][2], M[2][2]);
			
			// Remove the rotationX rotation from m2, so that the remaining
			// rotation, m2 is only around two axes, and gimbal lock cannot occur.
			m2.appendRotation(x*180/MathPI, new Vector3D(1, 0, 0));
			m2.append(m1);
			
			// Extract the other two angles, rot.y and rot.z, from m2.
			var cy:Number = Math.sqrt(m2.rawData[0]*m2.rawData[0] + m2.rawData[1]*m2.rawData[1]); // T cy = Math<T>::sqrt (N[0][0]*N[0][0] + N[0][1]*N[0][1]);
			
			y = Math.atan2(-m2.rawData[2], cy); // rot.y = Math<T>::atan2 (-N[0][2], cy);
			z = Math.atan2(-m2.rawData[4], m2.rawData[5]); //rot.z = Math<T>::atan2 (-N[1][0], N[1][1]);
			
			// Fix angles
			if(Math.round(z/MathPI) == 1) {
				if(y > 0)
					y = -(y - MathPI);
				else
					y = -(y + MathPI);
	
				z -= MathPI;
				
				if (x > 0)
					x -= MathPI;
				else
					x += MathPI;
			} else if(Math.round(z/MathPI) == -1) {
				if(y > 0)
					y = -(y - MathPI);
				else
					y = -(y + MathPI);
	
				z += MathPI;
				
				if (x > 0)
					x -= MathPI;
				else
					x += MathPI;
			} else if(Math.round(x/MathPI) == 1) {
				if(y > 0)
					y = -(y - MathPI);
				else
					y = -(y + MathPI);
	
				x -= MathPI;
				
				if (z > 0)
					z -= MathPI;
				else
					z += MathPI;
			} else if(Math.round(x/MathPI) == -1) {
				if(y > 0)
					y = -(y - MathPI);
				else
					y = -(y + MathPI);
	
				x += MathPI;
				
				if (z > 0)
					z -= MathPI;
				else
					z += MathPI;
			}
        }
        
        public function quaternion2euler(quarternion:Quaternion):void
		{
			
			var test :Number = quarternion.x*quarternion.y + quarternion.z*quarternion.w;
			if (test > 0.499) { // singularity at north pole
				x = 2 * Math.atan2(quarternion.x,quarternion.w);
				y = Math.PI/2;
				z = 0;
				return;
			}
			if (test < -0.499) { // singularity at south pole
				x = -2 * Math.atan2(quarternion.x,quarternion.w);
				y = - Math.PI/2;
				z = 0;
				return;
			}
		    
		    var sqx	:Number = quarternion.x*quarternion.x;
		    var sqy	:Number = quarternion.y*quarternion.y;
		    var sqz	:Number = quarternion.z*quarternion.z;
		    
		    x = Math.atan2(2*quarternion.y*quarternion.w - 2*quarternion.x*quarternion.z , 1 - 2*sqy - 2*sqz);
			y = Math.asin(2*test);
			z = Math.atan2(2*quarternion.x*quarternion.w-2*quarternion.y*quarternion.z , 1 - 2*sqx - 2*sqz);
		}
				
    	/**
    	 * Fill the 3d number object with the scale values represented by the 3x3 matrix.
    	 * 
    	 * @param	m	The 3d matrix object to use in the calculation.
    	 */
        public function matrix2scale(m:Matrix3D):void
        {
            x = Math.sqrt(m.rawData[0]*m.rawData[0] + m.rawData[1]*m.rawData[1] + m.rawData[2]*m.rawData[2]);
            y = Math.sqrt(m.rawData[4]*m.rawData[4] + m.rawData[5]*m.rawData[5] + m.rawData[6]*m.rawData[6]);
            z = Math.sqrt(m.rawData[8]*m.rawData[8] + m.rawData[9]*m.rawData[9] + m.rawData[10]*m.rawData[10]);
        }
        
        /**
         * Fills the 3d number object with values representing a point between the current and the
         * 3d number specified in parameter v. The f parameter defines the degree of interpolation 
         * between the two endpoints, where 0 represents the unmodified current values, and 1.0 
         * those of the v parameter.
         * 
         * @param w The target point.
         * @param f The level of interpolation between the current 3d number and the parameter v. 
         * 
         * @see flash.geom.Point.interpolate()
        */
        public function interpolate(w:Vector3D, f:Number):Vector3D
        {
        	var d:Vector3D = w.subtract(this);
        	d.scaleBy(f);
        	
        	return this.add(d);
        }
        
        /**
         * Returns a 3d number object representing a point between the two 3d number parameters w 
         * and v. The f parameter defines the degree of interpolation between the two ednpoints, 
         * where 0 or 1 will return 3d number objects equal to v and w respectively.
         * 
         * @param w The target point.
         * @param v The zero point.
         * @param f The level of interpolation where 0.0 will return a 3d number object equal to v,
         * and 1.0 will return a 3d number object equal to w.
         * 
         * @see flash.geom.Point.interpolate()
        */
        public static function getInterpolated(w:Vector3D, v:Vector3D, f:Number):Vector3D
        {
        	var d:Vector3D = w.subtract(v);
        	d.scaleBy(f);
        	
        	return d.add(v);
        }
        
        
        /**
        * A 3d number object representing a relative direction forward.
        */
        public static var FORWARD :Vector3D = new Vector3D( 0,  0,  1);
        
        /**
        * A 3d number object representing a relative direction backward.
        */
        public static var BACKWARD:Vector3D = new Vector3D( 0,  0, -1);
        
        /**
        * A 3d number object representing a relative direction left.
        */
        public static var LEFT    :Vector3D = new Vector3D(-1,  0,  0);
        
        /**
        * A 3d number object representing a relative direction right.
        */
        public static var RIGHT   :Vector3D = new Vector3D( 1,  0,  0);
        
        /**
        * A 3d number object representing a relative direction up.
        */
        public static var UP      :Vector3D = new Vector3D( 0,  1,  0);
        
        /**
        * A 3d number object representing a relative direction down.
        */
        public static var DOWN    :Vector3D = new Vector3D( 0, -1,  0);
        
        /**
        * Calculates a 3d number object representing the closest point on a given plane to a given 3d point.
        * 
        * @param	p	The 3d point used in teh calculation.
        * @param	k	The plane offset used in the calculation.
        * @param	n	The plane normal used in the calculation.
        * @return		The resulting 3d point.
        */
        public function closestPointOnPlane(p:Vector3D, k:Vector3D, n:Vector3D):Vector3D
        {
        	num = p.subtract(k);
            dist = n.dotProduct(num);
            num = n.clone();
            num.scaleBy(dist);
            num = p.subtract(num);
            
            return num;
        }
		
		/**
		 * Used to trace the values of a 3d number.
		 * 
		 * @return A string representation of the 3d number object.
		 */
        public override function toString(): String
        {
            return 'x:' + x + ' y:' + y + ' z:' + z;
        }
    }
}