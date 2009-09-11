package away3d.geom
{
	import away3d.core.base.DrawingCommand;
	import away3d.core.base.Element;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.Vertex;
	import away3d.core.math.Number3D;
	import away3d.core.utils.BezierUtils;

	public class AlignToPath
	{
		private var _originalMesh:Mesh;
		private var _activeMesh:Mesh;
		private var _path:Element;
		private var _curves:Array = [];
		private var _lengths:Array = [];
		private var _lengthArrays:Array = [];
		private var _totalLength:Number = 0;
		
		private var _arcLengthPrecision:Number = 0.01;
		
		/**
		 * Returns the quality of aligment parameter.
		 * @return Number
		 * 
		 */		
		public function get arcLengthPrecision():Number
		{
			return _arcLengthPrecision;
		}
		
		/**
		 * Determines the quality of the alignment.
		 * 
		 * The value is used to arc length parameterize the path. Without this technique
		 * the alignment would produce undesired scaling and squashing of the text.
		 * 
		 * The closer to zero, the better the quality of the alignment is, the larger the value
		 * the faster the performance of the aligment is.
		 * 
		 * @param value Number
		 * 
		 */		
		public function set arcLengthPrecision(value:Number):void
		{
			_arcLengthPrecision = value;
			
			if(_path)
				updatePath(_path);
		}
		
		/**
		 * Constructor. 
		 * @param mesh Mesh A mesh containing the elements to be aligned.
		 * @param path Element A Segment or a Face containing the path's vector data for the alignment.
		 * 
		 * NOTE: The inputed mesh will be cached, so updates to the mesh will need a new instance
		 * of the aligner.
		 * 
		 */		
		public function AlignToPath(mesh:Mesh, path:Element)
		{
			duplicateMesh(mesh);
			updatePath(path);
		}
		
		/**
		 * Updates the path of the alignment. 
		 * @param path Element A Segment or a Face containing the path's vector data for the alignment.
		 * @param precision Number Sets the arcLengthPrecision value.
		 * @return Number The aproximated arc length of the path.
		 * 
		 */		
		public function updatePath(path:Element, precision:Number = -1):Number
		{
			if(precision > 0)
				_arcLengthPrecision = precision;
				
			_path = path;
			
			_totalLength = 0;
			_lengthArrays = [];
			_lengths = [];
			_curves = [];
			
			// Identify the curves in the segment.
			for each(var command:DrawingCommand in _path.drawingCommands)
			{
				if(command.type != DrawingCommand.MOVE)
				{
					if(command.type == DrawingCommand.LINE)
						BezierUtils.createControlPointForLine(command);
					
					_curves.push(command);
				}
			}
			
			// Get arc length info for all curves.
			for each(command in _curves)
			{
				var commandLengthsArray:Array = BezierUtils.getArcLengthArray(command, _arcLengthPrecision);
				_lengthArrays.push(commandLengthsArray);
				
				var commandTotalLength:Number = commandLengthsArray[commandLengthsArray.length-1];
				_lengths.push(commandTotalLength);
				_totalLength += commandTotalLength;
			}
			
			return _totalLength;
		}
		
		/**
		 * Performs the alignment. 
		 * @param xOffset Number Determines the displacement of the alignment along the path.
		 * @param yOffset Number Determines the displacement of the alignment perpendicular to the path.
		 * @param restrain Boolean Forces the y alignment to face only 1 direction.
		 */		
		public function apply(xOffset:Number = 0, yOffset:Number = 0, restrain:Boolean = false):void
		{
			// NOTE: This method is yet to be optimized.
			
			var i:uint;
			var j:uint;
			var m:uint;
			var n:uint;
			
			// Warp the textfield's points onto the curve.
			for(m = 0; m<_originalMesh.faces.length; m++)
			{
				var origFace:Face = _originalMesh.faces[m];
				var transFace:Face = _activeMesh.faces[m];
				
				for(n = 0; n<origFace.vertices.length; n++)
				{
					var origVertex:Vertex = origFace.vertices[n];
					var transVertex:Vertex = transFace.vertices[n];
					
					// Get the x position marker for the vertex.
					var X:Number = origVertex.x + xOffset;
					
					if(X > 0)
					{
						while(X > _totalLength)
							X -= _totalLength;
					}
					else
					{
						while(X < 0)
							X += _totalLength;
					}
					
					// Evaluate into which curve the X marker falls.
					var acumLength:Number = 0;
					for(i = 0; i<_lengths.length; i++)
					{
						acumLength += _lengths[i];
						
						if(acumLength > X)
							break; // The loop breaks and i represents the index of the curve that contains the marker.
					}
					
					// Remove the last length from acumLength to obtain the local t in the landing curve.
					acumLength -= _lengths[i];
					var u:Number = (X - acumLength)/_lengths[i];
					
					// Arc-length parameterization.
					//-----------------------------------------------------------------
					// Find a t that yields uniform arc length.
					for(j = 0; j<_lengthArrays[i].length-2; j++)
					{
						var currentLength:Number = _lengthArrays[i][j];
						if(currentLength/_lengths[i] > u)
							break;
					}
					
					var t:Number = 0;
					if(_lengthArrays[i][j]/_lengths[i] == u)
					    t = j/(_lengthArrays[i].length - 1);
					else  // need to interpolate between two points
					{
					    var lengthBefore:Number = _lengthArrays[i][j];
					    var lengthAfter:Number = _lengthArrays[i][j+1];
					    var segmentLength:Number = lengthAfter - lengthBefore;
					
					    // determine where we are between the 'before' and 'after' points.
					    var segmentFraction:Number = (u*_lengths[i] - lengthBefore)/segmentLength;
					                          
					    // add that fractional amount to t 
					    t = (j + segmentFraction)/(_lengthArrays[i].length - 1);
					}
					//-----------------------------------------------------------------
					
					// Get the coordinates of the curve at t.
					var s:Vertex = BezierUtils.getCoordinatesAt(t, _curves[i]);
					
					// Get the normal at t.
					var tangent:Number3D = BezierUtils.getDerivativeAt(t, _curves[i]);
					
					var tX:Number = restrain ? -Math.abs(tangent.y) : -tangent.y;
					var tY:Number = restrain ? Math.abs(tangent.x) : tangent.x;
					var p:Number3D = new Number3D(tX, tY, 0);
					p.normalize(origVertex.y + yOffset);
					
					// Warp the point.
					transVertex.x = s.x + p.x;
					transVertex.y = s.y + p.y;
					transVertex.z = s.z + p.z;
				}
			}
		}
		
		/**
		 * Duplicates the mesh to be aligned.
		 * This is necessary in order to store an unaltered version of the mesh,
		 * otherwise alignments would be applied over each other and produce
		 * some pretty destructive effects.
		 * @param mesh Mesh
		 * 
		 */		
		private function duplicateMesh(mesh:Mesh):void
		{
			_activeMesh = mesh;
			
			_originalMesh = new Mesh();
			for each(var face:Face in mesh.faces)
			{
				_originalMesh.addFace(face.clone());
			}
		}
	}
}