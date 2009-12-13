package away3d.core.utils
{
	import away3d.core.base.*;
	import away3d.core.math.*;

	public class BezierUtils
	{
		public function BezierUtils()
		{
			
		}

		static public function splitDrawingCommand(curve:DrawingCommand):Array
		{
			if(curve.type == DrawingCommand.MOVE)
				return [curve];
			
			var pMidOnCurve:Vertex;
			var pMidStartControl:Vertex;
			var pMidControlEnd:Vertex;
			var command1:DrawingCommand;
			var command2:DrawingCommand;
			
			var type:String = curve.type;
			if(type == DrawingCommand.CURVE)
			{
				pMidOnCurve = BezierUtils.getCoordinatesAt(0.5, curve);
				pMidStartControl = BezierUtils.getMidPoint(curve.pStart, curve.pControl);
				pMidControlEnd = BezierUtils.getMidPoint(curve.pControl, curve.pEnd);
				
				command1 = new DrawingCommand(type, curve.pStart, pMidStartControl, pMidOnCurve);
				command2 = new DrawingCommand(type, pMidOnCurve, pMidControlEnd, curve.pEnd);
			}
			else
			{
				pMidOnCurve = BezierUtils.getMidPoint(curve.pStart, curve.pEnd);
				
				command1 = new DrawingCommand(type, curve.pStart, null, pMidOnCurve);
				command2 = new DrawingCommand(type, pMidOnCurve, null, curve.pEnd);
			}
			
			return [command1, command2];
		}
		
		static public function getMidPoint(p1:Vertex, p2:Vertex):Vertex
		{
			var mX:Number = (p1.x + p2.x)/2;
			var mY:Number = (p1.y + p2.y)/2;
			
			return new Vertex(mX, mY, 0);
		}
		
		static public function getCoordinatesAt(t:Number, curve:DrawingCommand):Vertex
		{
			var tSqr:Number = t*t;
			var invT:Number = 1 - t;
			var invTSqr:Number = invT*invT;
			
			var pX:Number = invTSqr*curve.pStart.x + 2*invT*t*curve.pControl.x + tSqr*curve.pEnd.x;
			var pY:Number = invTSqr*curve.pStart.y + 2*invT*t*curve.pControl.y + tSqr*curve.pEnd.y;
			var pZ:Number = invTSqr*curve.pStart.z + 2*invT*t*curve.pControl.z + tSqr*curve.pEnd.z;
			
			return new Vertex(pX, pY, pZ);
		}
		
		static public function createControlPointForLine(line:DrawingCommand):void
		{
			if(line.pControl)
				return;
				
			var pX:Number = (line.pStart.x + line.pEnd.x)/2;
			var pY:Number = (line.pStart.y + line.pEnd.y)/2;
			var pZ:Number = (line.pStart.z + line.pEnd.z)/2;
			
			line.pControl = new Vertex(pX, pY, pZ);
		}
		
		static public function getDerivativeAt(t:Number, curve:DrawingCommand):Number3D
		{
			var pX:Number = -2*(1 - t)*curve.pStart.x + 2*(1 - 2*t)*curve.pControl.x + 2*t*curve.pEnd.x;
			var pY:Number = -2*(1 - t)*curve.pStart.y + 2*(1 - 2*t)*curve.pControl.y + 2*t*curve.pEnd.y;
			var pZ:Number = -2*(1 - t)*curve.pStart.z + 2*(1 - 2*t)*curve.pControl.z + 2*t*curve.pEnd.z;
			
			return new Number3D(pX, pY, pZ);
		}
		
		static public function getArcLengthArray(curve:DrawingCommand, delta:Number):Vector.<Number>
		{
			// Get the points on the curve for the specifyed delta.
			var curvePoints:Vector.<Vertex> = new Vector.<Vertex>();
			for(var t:Number = 0; t <= 1; t += delta)
				curvePoints.push(BezierUtils.getCoordinatesAt(t, curve));
			
			// Incrementally calculate lengths and put them into an array.
			var acumLength:Number = 0;
			var lengths:Vector.<Number> = new Vector.<Number>();
			lengths.push(0);
			var loop:uint = curvePoints.length - 1;
			for(var i:uint; i<loop; ++i)
			{
				var pStart:Vertex = curvePoints[uint(i)];
				var pEnd:Vertex = curvePoints[uint(i+1)];
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