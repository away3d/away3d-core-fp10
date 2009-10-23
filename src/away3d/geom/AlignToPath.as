package away3d.geom
{
	import __AS3__.vec.Vector;
	
	import away3d.core.base.DrawingCommand;
	import away3d.core.base.Element;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.Vertex;
	import away3d.core.math.Number3D;
	import away3d.core.utils.BezierUtils;
	
	import flash.utils.Dictionary;

	public class AlignToPath
	{
		private var _originalMesh:Mesh;
		private var _activeMesh:Mesh;
		private var _path:Element;
		private var _curves:Vector.<DrawingCommand>;
		private var _lengths:Vector.<Number>;
		private var _lengthArrays:Vector.<Vector.<Number>>;
		private var _totalLength:Number = 0;
		private var _cachedVertices:Vector.<Vector.<Number3D>>;
		private var _cacheRef:Dictionary;
		private var _arcLengthPrecision:Number = 0.01;
		
		/**
		 * Constructor. 
		 * @param mesh Mesh A mesh containing the elements to be aligned.
		 * @param path Element A Segment or a Face containing the path's vector data for the alignment.
		 * NOTE: The inputed mesh will be cached, so updates to the mesh will need a new instance
		 * of the aligner.
		 */		
		public function AlignToPath(mesh:Mesh, path:Element)
		{
			duplicateMesh(mesh);
			updatePath(path);
			
			_cachedVertices = new Vector.<Vector.<Number3D>>();
			_cacheRef = new Dictionary();
		}
		
		/**
		 * Returns the last calculated length of the path.
		 * @return Number
		 */		
		public function get length():Number
		{
			return _totalLength;
		}
		
		/**
		 * Returns the quality of aligment parameter.
		 * @return Number
		 */		
		public function get arcLengthPrecision():Number
		{
			return _arcLengthPrecision;
		}
		
		/**
		 * Determines the quality of the alignment.
		 * The value is used to arc length parameterize the path. Without this technique
		 * the alignment would produce undesired scaling and squashing of the text.
		 * The closer to zero, the better the quality of the alignment is, the larger the value
		 * the faster the performance of the aligment is.
		 * @param value Number
		 */		
		public function set arcLengthPrecision(value:Number):void
		{
			_arcLengthPrecision = value;
			
			if(_path)
				updatePath(_path);
		}
		
		/**
		 * Updates the path of the alignment. 
		 * @param path Element A Segment or a Face containing the path's vector data for the alignment.
		 * @param precision Number Sets the arcLengthPrecision value.
		 * @return Number The aproximated arc length of the path.
		 */		
		public function updatePath(path:Element, precision:Number = -1):Number
		{
			if(precision > 0)
				_arcLengthPrecision = precision;
				
			_path = path;
			
			_totalLength = 0;
			_lengthArrays = new Vector.<Vector.<Number>>();
			_lengths = new Vector.<Number>();
			_curves = new Vector.<DrawingCommand>();
			
			// Identify the curves in the segment.
			var i:uint;
			var loop:uint = _path.drawingCommands.length;
			for(i = 0; i<loop; ++i)
			{
				var command:DrawingCommand = _path.drawingCommands[uint(i)];
				if(command.type != DrawingCommand.MOVE)
				{
					if(command.type == DrawingCommand.LINE)
						BezierUtils.createControlPointForLine(command);
					_curves.push(command);
				}
			}
			
			// Get arc length info for all curves.
			loop = _curves.length;
			for(i = 0; i<loop; ++i)
			{
				command = _curves[uint(i)];
				
				var commandLengthsArray:Vector.<Number> = BezierUtils.getArcLengthArray(command, _arcLengthPrecision);
				_lengthArrays.push(commandLengthsArray);
				
				var commandTotalLength:Number = commandLengthsArray[commandLengthsArray.length-1];
				_lengths.push(commandTotalLength);
				_totalLength += commandTotalLength;
			}
			
			return _totalLength;
		}
		
		/**
		 * Given a point in space, this method finds the offset in
		 * the curve that represents the closest point in the curve
		 * to the specified point in space. 
		 * @param point Point The loose point in space.
		 * @return Number The offset in the curve that yields the closest
		 * point in the curve to the specified point.
		 */		
		public function findClosestCurveOffsetToPoint(point:Number3D):Object
		{
			// Evaluates distances to all control points in the path
			// in order to determine which is the closest curve.
			var minimunDistance:Number = Number.MAX_VALUE;
			var minimunDistanceIndex:uint;
			var loop:uint = _curves.length;
			for(var i:uint; i<loop; ++i)
			{
				var command:DrawingCommand = _curves[uint(i)];
				var control:Vertex = command.pControl;
				
				var dX:Number = control.x - point.x;
				var dY:Number = control.y - point.y;
				var dZ:Number = control.z - point.z;
				
				var dis:Number = Math.sqrt(dX*dX + dY*dY + dZ*dZ);
				
				if(dis < minimunDistance)
				{
					minimunDistance = dis;
					minimunDistanceIndex = i;
				}
			}
			
			// Finds the cumulative arc-length of the path
			// until the closest curve is reached.
			var offset:Number = 0;
			for(i = 0; i<minimunDistanceIndex; ++i)
				offset += _lengths[i];
				
			offset -= _lengths[minimunDistanceIndex];
			
			// TO-DO: Use arc-length parameterization to obtain
			// the closest value within the curve.
			minimunDistance = Number.MAX_VALUE;
			var distancesArr:Vector.<Number> = BezierUtils.getArcLengthArray(_curves[minimunDistanceIndex], 0.1);
			var pCurvehit:Vertex;
			var minimunDistanceIndex1:uint;
			for(i = 0; i<10; ++i)
			{
				var pCurve:Vertex = BezierUtils.getCoordinatesAt(i/10, _curves[minimunDistanceIndex]);
				
				dX = pCurve.x - point.x;
				dY = pCurve.y - point.y;
				dZ = pCurve.z - point.z;
				
				dis = Math.sqrt(dX*dX + dY*dY + dZ*dZ);
				
				if(dis < minimunDistance)
				{
					minimunDistance = dis;
					minimunDistanceIndex1 = i;
					pCurvehit = pCurve;
				}
			}
			
			for(i = 0; i<minimunDistanceIndex1; ++i)
				offset += distancesArr[uint(i)];
			
			// Identifies the point in the curve.
			//var closestPoint:Vertex = _curves[minimunDistanceIndex].pStart;
			
			// TO-DO: Avoid returning an object.
			return {point:pCurvehit, offset:offset};
		}
		
		/**
		 * Traverses the entire path with a given offset,
		 * storing the vertex positions. Could yield pretty intensive calculation.
		 * The idea is to use this to precalculate alignments for later used with applyCached().
		 * @param divisions The number of snapshots to take. If the length of the path is 100px,
		 * a division of 50 would store alignment for an xOffset with 2px increment.
		 * @param yOffset See apply().
		 * @param restrain See apply().
		 * @param fast See apply().
		 */		
		public function buildCache(divisions:Number, yOffset:Number, restrain:Boolean = false, fast:Boolean = false):void
		{
			_cachedVertices = new Vector.<Vector.<Number3D>>();
			
			for(var i:Number = 0; i < _totalLength; i += _totalLength/divisions)
			{
				apply(i, yOffset, restrain, fast);
				
				var snapshot:Array = [];
				for each(var face:Face in _activeMesh.faces)
				{
					for each(var vertex:Vertex in face.vertices)
						snapshot.push(new Number3D(vertex.x, vertex.y, vertex.z));
				}
				_cachedVertices.push(snapshot);
			}
		}
		
		/**
		 * Caches the warped vertex positions of the mesh at a given x offset.
		 * To recall positions cached in this way use applyCachedAt(). 
		 * @param xOffset The x offset to cache. See apply().
		 * @param yOffset See apply().
		 * @param restrain See apply().
		 * @param fast See apply().
		 */		
		public function buildCacheAt(xOffset:Number = 0, yOffset:Number = 0, restrain:Boolean = false, fast:Boolean = false):void
		{
			apply(xOffset, yOffset, restrain, fast);
				
			var snapshot:Vector.<Number3D> = new Vector.<Number3D>();
			var i:uint, j:uint;
			var loop:uint = _activeMesh.faces.length;
			for(i = 0; i<loop; ++i)
			{
				var face:Face = _activeMesh.faces[uint(i)];
				
				var subLoop:uint = face.vertices.length;
				var vertices:Array = face.vertices;
				for(j = 0; j<subLoop; ++j)
				{
					var vertex:Vertex = vertices[uint(j)];
					snapshot.push(new Number3D(vertex.x, vertex.y, vertex.z));
				}
			}
			_cachedVertices.push(snapshot);
			
			_cacheRef[xOffset] = snapshot;
		}
		
		/**
		 * See buildCacheAt();
		 * @param xOffset The x offset to restore.
		 */		
		public function applyCachedAt(xOffset:Number = 0):void
		{
			var snapshot:Vector.<Number3D> = _cacheRef[xOffset];
			
			var i:uint, a:uint, b:uint;
			var loop:uint = _activeMesh.faces.length;
			var arr:Array = _activeMesh.faces;
			for(a = 0; a<loop; ++a)
			{
				var face:Face = arr[uint(a)];
				var subLoop:uint = face.vertices.length;
				var subArr:Array = face.vertices;
				for(b = 0; b<subLoop; ++b)
				{
					var vertex:Vertex = face.vertices[uint(b)];
					
					if(!snapshot[uint(i)])
						continue;
					
					vertex.x = snapshot[uint(i)].x;
					vertex.y = snapshot[uint(i)].y;
					vertex.z = snapshot[uint(i)].z;
					
					i++;
				}
			}
		}
		
		/**
		 * Performs the alignment from precalculations.
		 * buildCache() must be called first. See buildCache().
		 * @param index uint Specifyes the index in the cached alignments to use,
		 * or which snapshot.
		 */		
		public function applyCached(index:uint):void
		{
			var snapshot:Vector.<Number3D> = _cachedVertices[index];
			
			if(!snapshot)
				return;
			
			var i:uint;
			for each(var face:Face in _activeMesh.faces)
			{
				for each(var vertex:Vertex in face.vertices)
				{
					if(!snapshot[i])
						continue;
					
					vertex.x = snapshot[i].x;
					vertex.y = snapshot[i].y;
					vertex.z = snapshot[i].z;
					
					i++;
				}
			}
		}
		
		/**
		 * Performs the alignment. 
		 * @param xOffset Number Determines the displacement of the alignment along the path.
		 * @param yOffset Number Determines the displacement of the alignment perpendicular to the path.
		 * @param restrain Boolean Forces the y alignment to face only 1 direction.
		 * @param fast Boolean If true, omits arc-length parameterization yielding less precise, but faster results.
		 */		
		public function apply(xOffset:Number = 0, yOffset:Number = 0, restrain:Boolean = false, fast:Boolean = false):void
		{
			// NOTE: This method is yet to be optimized.
			
			var i:uint;
			var j:uint;
			var m:uint;
			var n:uint;
			
			// Warp the textfield's points onto the curve.
			var loop:uint, subLoop:uint, subSubLoop:uint, subSubSubLoop:uint;
			loop = _originalMesh.faces.length;
			for(m = 0; m<loop; ++m)
			{
				var origFace:Face = _originalMesh.faces[uint(m)];
				var transFace:Face = _activeMesh.faces[uint(m)];
				
				subLoop = origFace.vertices.length;
				for(n = 0; n<subLoop; ++n)
				{
					var origVertex:Vertex = origFace.vertices[uint(n)];
					var transVertex:Vertex = transFace.vertices[uint(n)];
					
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
					subSubLoop = _lengths.length;
					for(i = 0; i<subSubLoop; ++i)
					{
						acumLength += _lengths[uint(i)];
						
						if(acumLength > X)
							break; // The loop breaks and i represents the index of the curve that contains the marker.
					}
					
					// Remove the last length from acumLength to obtain the local t in the landing curve.
					acumLength -= _lengths[uint(i)];
					var u:Number = (X - acumLength)/_lengths[uint(i)];
					
					if(!fast)
					{
						// Arc-length parameterization.
						//-----------------------------------------------------------------
						// Find a t that yields uniform arc length.
						subSubSubLoop = _lengthArrays[uint(i)].length-2;
						for(j = 0; j<subSubSubLoop; ++j)
						{
							var currentLength:Number = _lengthArrays[uint(i)][uint(j)];
							if(currentLength/_lengths[uint(i)] > u)
								break;
						}
						
						var t:Number = 0;
						if(_lengthArrays[uint(i)][uint(j)]/_lengths[uint(i)] == u)
						    t = j/(_lengthArrays[uint(i)].length - 1);
						else  // need to interpolate between two points
						{
						    var lengthBefore:Number = _lengthArrays[uint(i)][uint(j)];
						    var lengthAfter:Number = _lengthArrays[uint(i)][uint(j+1)];
						    var segmentLength:Number = lengthAfter - lengthBefore;
						
						    // determine where we are between the 'before' and 'after' points.
						    var segmentFraction:Number = (u*_lengths[uint(i)] - lengthBefore)/segmentLength;
						                          
						    // add that fractional amount to t 
						    t = (j + segmentFraction)/(_lengthArrays[uint(i)].length - 1);
						}
						//-----------------------------------------------------------------
					}
					else
						t = u;
					
					// Get the coordinates of the curve at t.
					var s:Vertex = BezierUtils.getCoordinatesAt(t, _curves[uint(i)]);
					
					// Get the normal at t.
					var tangent:Number3D = BezierUtils.getDerivativeAt(t, _curves[uint(i)]);
					
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