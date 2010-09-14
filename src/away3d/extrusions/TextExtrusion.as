package away3d.extrusions
{
	import away3d.core.base.*;
	import away3d.core.geom.*;
	import away3d.core.utils.*;
	import away3d.materials.*;
	
	import flash.geom.*;
	
	public class TextExtrusion extends Mesh
	{
		private var _mesh:Mesh;
		private var _face:Face;
		private var _subdivisionsZ:Number;
		private var _subdivisionsXY:Number;
		private var _depth:Number;
		private var _effectivePathCommands:Array;
		private var _material:Material;
		
		public function TextExtrusion(mesh:Mesh, init:Object=null)
		{
			super(init);
			
			_mesh = mesh;
			_face = face;
			_subdivisionsZ = ini.getNumber("subdivisionsZ", 1, {min:1, max:100});
			_subdivisionsXY = ini.getNumber("subdivisionsXY", 1, {min:1, max:100});
			_depth = ini.getNumber("depth", 100);
			
			_material = mesh.material as Material;
			
			for each(var face:Face in mesh.faces)
				generateFaceExtrusion(face);
		}
		
		private function generateFaceExtrusion(face:Face):void
		{
			_face = face;
			
			_effectivePathCommands = _face.pathCommands;
			for(var i:uint; i<_subdivisionsXY-1; i++)
				splitPathCommands();
			
			extrudePathCommands();
		}
		
		private function splitPathCommands():void
		{
			var tempArray:Array = _effectivePathCommands.concat();
			for(var i:uint; i<tempArray.length; i++)
			{
				var splitCommands:Array = BezierUtils.splitPathCommand(tempArray[i]);
				
				for each(var generatedCommand:PathCommand in splitCommands)
					_effectivePathCommands.push(generatedCommand);
			}
		}
		
		private function extrudePathCommands():void
		{
			var i:uint;
			var j:uint;
			var depth:Number;
			var depthOffset:Number;
			var subdivisionUnit:Number = _depth/_subdivisionsZ;
			for(i = 0; i<_face.pathCommands.length; i++)
			{
				var drawingCommand:PathCommand = _effectivePathCommands[i];
				
				if(drawingCommand.type != PathCommand.MOVE)
				{
					for(j = 0; j<_subdivisionsZ; j++)
					{
						depth = subdivisionUnit;
						depthOffset = j*_depth/_subdivisionsZ;
						
						generatePathCommandExtrusion(drawingCommand, depth, depthOffset);
					}
				}
			}
		}
		
		private function generatePathCommandExtrusion(drawingCommand:PathCommand, depth:Number, depthOffset:Number):void
		{
			var originalStart:Vector3D = drawingCommand.pStart || new Vector3D();
			var originalControl:Vector3D = drawingCommand.pControl || new Vector3D();
			var originalEnd:Vector3D = drawingCommand.pEnd;
			
			var pStart:Vector3D = new Vector3D(originalStart.x, originalStart.y, originalStart.z + depthOffset);
			var pControl:Vector3D = new Vector3D(originalControl.x, originalControl.y, originalControl.z + depthOffset);
			var pEnd:Vector3D = new Vector3D(originalEnd.x, originalEnd.y, originalEnd.z + depthOffset);
			
			var pStartOffset:Vector3D = new Vector3D(pStart.x, pStart.y, pStart.z + depth);
			var pControlOffset:Vector3D = new Vector3D(pControl.x, pControl.y, pControl.z + depth);
			var pEndOffset:Vector3D = new Vector3D(pEnd.x, pEnd.y, pEnd.z + depth);
			
			var face:Face = new Face();
			face.material = _material;
		
		 	face.moveTo(_mesh.x + pStart.x, _mesh.y + pStart.y, pStart.z);
			
			face.lineTo(_mesh.x + pStartOffset.x, _mesh.y + pStartOffset.y, pStartOffset.z);
			
			if(drawingCommand.type == PathCommand.LINE)
				face.lineTo(_mesh.x + pEndOffset.x, _mesh.y + pEndOffset.y, pEndOffset.z);
			else if(drawingCommand.type == PathCommand.CURVE)
				face.curveTo(_mesh.x + pControlOffset.x, _mesh.y + pControlOffset.y, pControlOffset.z, _mesh.x + pEndOffset.x, _mesh.y + pEndOffset.y, pEndOffset.z);
				
			face.lineTo(_mesh.x + pEnd.x, _mesh.y + pEnd.y, pEnd.z);
			
			var pStartAux:Vector3D = new Vector3D(originalStart.x, originalStart.y, originalStart.z + depthOffset);
			if(drawingCommand.type == PathCommand.LINE)
				face.lineTo(_mesh.x + pStartAux.x, _mesh.y + pStartAux.y, pStartAux.z);
			else if(drawingCommand.type == PathCommand.CURVE)
				face.curveTo(_mesh.x + pControl.x, _mesh.y + pControl.y, pControl.z, _mesh.x + pStartAux.x, _mesh.y + pStartAux.y, pStartAux.z); 
				
			addFace(face); 
		}
	}
}