package away3d.core.utils
{
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.geom.*;
	
	import flash.geom.*;
	
	use namespace arcane;
	
	/**
	 * @author Rob
	 */
	public class FaceUtils
	{
		
		/**
		 * Tests if an edge of the face lies on a given plane
		 * @param plane The plane to test against
		 * @return Whether or not an edge of this Face lies on the plane 
		 */
		public static function hasEdgeOnPlane(face:Face, plane:Plane3D, epsilon:Number = 0.001) : Boolean
		{
			var v0 : Vertex = face.vertices[0];
			var v1 : Vertex = face.vertices[1];
			var v2 : Vertex = face.vertices[2];
			var numEdge : int;
			var d0 : Number, d1 : Number, d2 : Number;
			var align : int = plane._alignment;
			var a : Number = plane.a,
				b : Number = plane.b,
				c : Number = plane.c,
				d : Number = plane.d;

			if (align == Plane3D.X_AXIS) {
				d0 = a*v0._x + d;
				d1 = a*v1._x + d;
				d2 = a*v2._x + d;
			}
			else if (align == Plane3D.Y_AXIS) {
				d0 = b*v0._y + d;
				d1 = b*v1._y + d;
				d2 = b*v2._y + d;
			}
			else if (align == Plane3D.Z_AXIS) {
				d0 = c*v0._z + d;
				d1 = c*v1._z + d;
				d2 = c*v2._z + d;
			}
			else {
				d0 = a*v0._x + b*v0._y + c*v0._z + d;
				d1 = a*v1._x + b*v1._y + c*v1._z + d;
				d2 = a*v2._x + b*v2._y + c*v2._z + d;
			}
			if (d0 <= epsilon && d0 >= -epsilon) ++numEdge;
			if (d1 <= epsilon && d1 >= -epsilon) ++numEdge;
			if (d2 <= epsilon && d2 >= -epsilon) ++numEdge;

			return numEdge > 1;
		}
		
		
        /**
         * Scales the face by a given factor about its unweighed center.
         * NOTE: Supports only irregular faces for now. 
         * @param scale [Number] The amount factor to scale the face.
         * 
         */    
        public static function scaleAboutCenter(face:Face, scale:Number):void
        {
        	var minX:Number = Number.MAX_VALUE;
        	var maxX:Number = -Number.MAX_VALUE;
        	var minY:Number = Number.MAX_VALUE;
        	var maxY:Number = -Number.MAX_VALUE;
        	var minZ:Number = Number.MAX_VALUE;
        	var maxZ:Number = -Number.MAX_VALUE;
        	var i:uint;
        	var command:PathCommand;
			
			for(i = 0; i<face.pathCommands.length; i++)
			{
				command = face.pathCommands[i];
				if(command.pControl)
				{
					if(command.pControl.x < minX)
						minX = command.pControl.x;
					if(command.pControl.x > maxX)
						maxX = command.pControl.x;
					if(command.pControl.y < minY)
						minY = command.pControl.y;
					if(command.pControl.y > maxY)
						maxY = command.pControl.y;
					if(command.pControl.z < minZ)
						minZ = command.pControl.z;
					if(command.pControl.z > maxZ)
						maxZ = command.pControl.z;
				}
				if(command.pEnd)
				{
					if(command.pEnd.x < minX)
						minX = command.pEnd.x;
					if(command.pEnd.x > maxX)
						maxX = command.pEnd.x;
					if(command.pEnd.y < minY)
						minY = command.pEnd.y;
					if(command.pEnd.y > maxY)
						maxY = command.pEnd.y;
					if(command.pEnd.z < minZ)
						minZ = command.pEnd.z;
					if(command.pEnd.z > maxZ)
						maxZ = command.pEnd.z;
				}
			}
			
			var unweighedCenter:Vector3D = new Vector3D((maxX + minX)/2, (maxY + minY)/2, (maxZ + minZ)/2);
			for(i = 0; i<face.pathCommands.length; i++)
			{
				command = face.pathCommands[i];
				if(command.pControl)
				{
					var pControlCenterVec:Vector3D = new Vector3D(command.pControl.x, command.pControl.y, command.pControl.z);
					pControlCenterVec = pControlCenterVec.subtract(unweighedCenter);
					pControlCenterVec.scaleBy(scale);
					command.pControl.x = unweighedCenter.x + pControlCenterVec.x;
					command.pControl.y = unweighedCenter.y + pControlCenterVec.y;
					command.pControl.z = unweighedCenter.z + pControlCenterVec.z;
				}
				if(command.pEnd)
				{
					var pEndCenterVec:Vector3D = new Vector3D(command.pEnd.x, command.pEnd.y, command.pEnd.z);
					pEndCenterVec = pEndCenterVec.subtract(unweighedCenter);
					pEndCenterVec.scaleBy(scale);
					command.pEnd.x = unweighedCenter.x + pEndCenterVec.x;
					command.pEnd.y = unweighedCenter.y + pEndCenterVec.y;
					command.pEnd.z = unweighedCenter.z + pEndCenterVec.z;
				}
			}
        }
	}
}
