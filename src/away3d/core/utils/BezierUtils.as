package away3d.core.utils
{
	import away3d.core.geom.*;
	
	import flash.geom.*;
	
	public class BezierUtils
	{
		public function BezierUtils()
		{
			
		}

		static public function splitPathCommand(command:PathCommand):Array
		{
			if(command.type == PathCommand.MOVE)
				return [command];
			
			var pMidOnCurve:Vector3D;
			var pMidStartControl:Vector3D;
			var pMidControlEnd:Vector3D;
			var command1:PathCommand;
			var command2:PathCommand;
			
			var type:String = command.type;
			if(type == PathCommand.CURVE)
			{
				pMidOnCurve = BezierUtils.getCoordinatesAt(0.5, command);
				pMidStartControl = BezierUtils.getMidPoint(command.pStart, command.pControl);
				pMidControlEnd = BezierUtils.getMidPoint(command.pControl, command.pEnd);
				
				command1 = new PathCommand(type, command.pStart, pMidStartControl, pMidOnCurve);
				command2 = new PathCommand(type, pMidOnCurve, pMidControlEnd, command.pEnd);
			}
			else
			{
				pMidOnCurve = BezierUtils.getMidPoint(command.pStart, command.pEnd);
				
				command1 = new PathCommand(type, command.pStart, null, pMidOnCurve);
				command2 = new PathCommand(type, pMidOnCurve, null, command.pEnd);
			}
			
			return [command1, command2];
		}
		
		static public function getMidPoint(p1:Vector3D, p2:Vector3D):Vector3D
		{
			var mX:Number = (p1.x + p2.x)/2;
			var mY:Number = (p1.y + p2.y)/2;
			
			return new Vector3D(mX, mY, 0);
		}
		
		static public function getCoordinatesAt(t:Number, command:PathCommand):Vector3D
		{
			var tSqr:Number = t*t;
			var invT:Number = 1 - t;
			var invTSqr:Number = invT*invT;
			
			var pX:Number = invTSqr*command.pStart.x + 2*invT*t*command.pControl.x + tSqr*command.pEnd.x;
			var pY:Number = invTSqr*command.pStart.y + 2*invT*t*command.pControl.y + tSqr*command.pEnd.y;
			var pZ:Number = invTSqr*command.pStart.z + 2*invT*t*command.pControl.z + tSqr*command.pEnd.z;
			
			return new Vector3D(pX, pY, pZ);
		}
		
		static public function createControlPointForLine(line:PathCommand):void
		{
			if(line.pControl)
				return;
				
			var pX:Number = (line.pStart.x + line.pEnd.x)/2;
			var pY:Number = (line.pStart.y + line.pEnd.y)/2;
			var pZ:Number = (line.pStart.z + line.pEnd.z)/2;
			
			line.pControl = new Vector3D(pX, pY, pZ);
		}
		
		static public function getDerivativeAt(t:Number, command:PathCommand):Vector3D
		{
			var pX:Number = -2*(1 - t)*command.pStart.x + 2*(1 - 2*t)*command.pControl.x + 2*t*command.pEnd.x;
			var pY:Number = -2*(1 - t)*command.pStart.y + 2*(1 - 2*t)*command.pControl.y + 2*t*command.pEnd.y;
			var pZ:Number = -2*(1 - t)*command.pStart.z + 2*(1 - 2*t)*command.pControl.z + 2*t*command.pEnd.z;
			
			return new Vector3D(pX, pY, pZ);
		}
		
		static public function getArcLengthArray(command:PathCommand, delta:Number):Vector.<Number>
		{
			// Get the points on the command for the specified delta.
			var commandPoints:Vector.<Vector3D> = new Vector.<Vector3D>();
			for(var t:Number = 0; t <= 1; t += delta)
				commandPoints.push(BezierUtils.getCoordinatesAt(t, command));
			
			// Incrementally calculate lengths and put them into an array.
			var acumLength:Number = 0;
			var lengths:Vector.<Number> = new Vector.<Number>();
			lengths.push(0);
			var loop:uint = commandPoints.length - 1;
			for(var i:uint; i<loop; ++i)
			{
				var pStart:Vector3D = commandPoints[uint(i)];
				var pEnd:Vector3D = commandPoints[uint(i+1)];
				var dX:Number = pEnd.x - pStart.x;
				var dY:Number = pEnd.y - pStart.y;
				var dZ:Number = pEnd.z - pStart.z;
				var len:Number = Math.sqrt(dX*dX + dY*dY + dZ*dZ);
				acumLength += len;
				lengths.push(acumLength);
			}
			
			return lengths;
		}
	}
}