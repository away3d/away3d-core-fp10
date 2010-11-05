package away3d.core.utils 
{
	import away3d.arcane;
	import away3d.cameras.lenses.*;
	import away3d.core.base.*;
	import away3d.core.geom.*;
	import away3d.core.project.*;
	import away3d.core.render.*;
	import away3d.core.vos.*;
	import away3d.materials.*;
	
	import flash.geom.*;
	
	use namespace arcane;
	
	/**
	 * @author robbateman
	 */
	public class ViewSourceObject 
	{
		private var _v0x:Number;
        private var _v0y:Number;
        private var _v0z:Number;
        private var _v1x:Number;
        private var _v1y:Number;
        private var _v1z:Number;
        private var _v2x:Number;
        private var _v2y:Number;
        private var _v2z:Number;
        private var _v0u:Number;
        private var _v0v:Number;
        private var _v1u:Number;
        private var _v1v:Number;
        private var _v2u:Number;
        private var _v2v:Number;
		
		private var _dx:Number;
		private var _dy:Number;
        private var _ax:Number;
        private var _bx:Number;
        private var _cx:Number;
        private var _ay:Number;
        private var _by:Number;
        private var _cy:Number;
		
		private var _det:Number;
        private var _da:Number;
        private var _db:Number;
        private var _dc:Number;
		
		private var _index:uint;
		private var _sv0x:Number;
		private var _sv0y:Number;
		private var _sv1x:Number;
		private var _sv1y:Number;
		private var _sv2x:Number;
		private var _sv2y:Number;
        
        private var _startIndex:uint;
        private var _endIndex:uint;
        private var _faceVO:FaceVO;
        private var _segmentVO:SegmentVO;
        private var _material:Material;
        private var _index0:uint;
        private var _index1:uint;
        private var _index2:uint;
        private var _index3:uint;
        private var _index4:uint;
        private var _uvs:Vector.<UV>;
        private var _priLength:uint;
        private var _vertexIndex:uint;
        private var segmentCommands:Vector.<String> = Vector.<String>(["M", "L"]);
        private var faceCommands:Vector.<String> = Vector.<String>(["M", "L", "L"]);
        
        private function getEndLoopIndex(i:uint):uint
        {
        	var j:uint = i + 1;
        	
        	while(j < _endIndex && _faceVO.commands[j - _startIndex] != PathCommand.MOVE)
        		j++;
        	
        	return j - 1;
        }
        
        private function getMedian(aindex:Number, bindex:Number):void
        {
			var avertex:int = screenIndices[aindex]*2;
        	var ax:Number = screenVertices[avertex];
        	var ay:Number = screenVertices[uint(avertex+1)];
        	var az:Number = screenUVTs[uint(screenIndices[aindex]*3+2)];
        	
        	var bvertex:int = screenIndices[bindex]*2;
        	var bx:Number = screenVertices[bvertex];
        	var by:Number = screenVertices[uint(bvertex+1)];
        	var bz:Number = screenUVTs[uint(screenIndices[bindex]*3+2)];
        	
            var mz:Number = (1/az + 1/bz) / 2;
			
            var faz:Number = 1/az;
            var fbz:Number = 1/bz;
            var ifmz:Number = 1 / mz / 2;
			
			screenVertices[screenVertices.length] = (ax*faz + bx*fbz)*ifmz;
			screenVertices[screenVertices.length] = (ay*faz + by*fbz)*ifmz;
			screenUVTs.push(0, 0, 1/mz);
        }
        
        private function distanceSqr(ax:Number, ay:Number, bx:Number, by:Number):Number
        {
            return (ax - bx)*(ax - bx) + (ay - by)*(ay - by);
        }
        
		public var source:Object3D;
		public var screenVertices:Vector.<Number>;
		public var screenIndices:Vector.<int>;
		public var screenUVTs:Vector.<Number>;
		public var screenTransform:Matrix3D;
		
		public function ViewSourceObject(source:Object3D)
		{
			this.source = source;
		}
		
		        
        public function contains(priIndex:uint, renderer:Renderer, x:Number, y:Number):Boolean
        {
			_startIndex = renderer.primitiveProperties[uint(priIndex*9)];
			
			switch (renderer.primitiveType[priIndex]) {
        		case PrimitiveType.FACE:
					_endIndex = renderer.primitiveProperties[uint(priIndex*9 + 1)];
        			//use crossing count on an infinite ray projected from the test point along the x axis
	        		var c:Boolean = false;
	        		var i:uint = _startIndex;
	        		var j:uint;
	        		var vertix:Number;
	        		var vertiy:Number;
	        		var vertjx:Number;
	        		var vertjy:Number;
	        		var iIndex:uint;
	        		var jIndex:uint;
	        		
	        		_faceVO = renderer.primitiveElements[priIndex] as FaceVO;
					while (i < _endIndex) {
						if (_faceVO.commands[i - _startIndex] == PathCommand.MOVE)
							j = getEndLoopIndex(i);
						
						if (_faceVO.commands[i - _startIndex] == PathCommand.CURVE)
							i++;
						
						if ((((vertiy = screenVertices[uint((iIndex = screenIndices[i]*2) + 1)]) > y) != ((vertjy = screenVertices[uint((jIndex = screenIndices[j]*2) + 1)]) > y)) && (x < ((vertjx = screenVertices[jIndex]) - (vertix = screenVertices[iIndex]))*(y - vertiy)/(vertjy - vertiy) + vertix))
							c = !c;
						
						j = i++;
						
					}
					return c;
					
				case PrimitiveType.SEGMENT:
					_index = screenIndices[_startIndex]*2;
        			_v0x = screenVertices[_index];
        			_v0y = screenVertices[uint(_index + 1)];
        			_index = screenIndices[uint(_startIndex + 1)]*2;
        			_v1x = screenVertices[_index];
        			_v1y = screenVertices[uint(_index + 1)];
        			if (Math.abs(_v0x*(y - _v1y) + _v1x*(_v0y - y) + x*(_v1y - _v0y)) > 0.001*1000*1000)
		                return false;
					
					var centerX:Number = (_v0x + _v1x) / 2 - x;
            		var centerY:Number = (_v0y + _v1y) / 2 - y;
            		var lengthX:Number = (_v1x - _v0x);
            		var lengthY:Number = (_v1y - _v0y);
            		
		            if ((centerX*centerX + centerY*centerY)*4 > lengthX*lengthX + lengthY*lengthY)
		                return false;
		
		            return true;
        		case PrimitiveType.SPRITE3D:
		            var scale:Number = renderer.primitiveProperties[uint(priIndex*9 + 8)];
					var spriteVO:SpriteVO = renderer.primitiveElements[priIndex] as SpriteVO;
					var pointMapping:Matrix = spriteVO.mapping.clone();
					var bMaterial:BitmapMaterial;
					if ((bMaterial = spriteVO.material as BitmapMaterial)) {
			            pointMapping.scale(scale*bMaterial.width, scale*bMaterial.height);
					} else {
			            pointMapping.scale(scale*spriteVO.width, scale*spriteVO.height);
					}
					
					_index = screenIndices[_startIndex]*2;
		            pointMapping.translate(screenVertices[_index], screenVertices[uint(_index + 1)]);
		            pointMapping.invert();
		            
		            var p:Point = pointMapping.transformPoint(new Point(x, y));
					
		            if (p.x < 0)
		                return false;
		            if (p.y < 0)
		                return false;
		            if (p.x > spriteVO.width)
		                return false;
		            if (p.y > spriteVO.height)
		                return false;
					
					var bitmapMaterial:BitmapMaterial = spriteVO.material as BitmapMaterial;
		            
		            if (!bitmapMaterial || !bitmapMaterial.bitmap.transparent)
		                return true;
		            
		            return uint(bitmapMaterial.bitmap.getPixel32(int(p.x), int(p.y)) >> 24) > 0x80;
        		case PrimitiveType.DISPLAY_OBJECT:
					return true;
				default:
					return false;
			}
        }
        
        public function getUVT(priIndex:uint, renderer:Renderer, x:Number, y:Number):Vector3D
        {
        	_startIndex = renderer.primitiveProperties[uint(priIndex*9)];
        	
        	switch (renderer.primitiveType[priIndex]) {
        		case PrimitiveType.FACE:
					_endIndex = renderer.primitiveProperties[uint(priIndex*9 + 1)];
					
					if (_endIndex - _startIndex > 3)
						return new Vector3D(0, 0, renderer.primitiveScreenZ[priIndex]);
					
					_uvs = renderer.primitiveUVs[priIndex];
					_index0 = screenIndices[_startIndex];
					_v0x = screenVertices[uint(_index0*2)];
					_v0y = screenVertices[uint(_index0*2 + 1)];
					_v0z = screenUVTs[uint(_index0*3 + 2)];
        			_index1 = screenIndices[uint(_startIndex + 1)];
        			_v1x = screenVertices[uint(_index1*2)];
        			_v1y = screenVertices[uint(_index1*2 + 1)];
        			_v1z = screenUVTs[uint(_index1*3 + 2)];
        			_index2 = screenIndices[uint(_startIndex + 2)];
        			_v2x = screenVertices[uint(_index2*2)];
        			_v2y = screenVertices[uint(_index2*2 + 1)];
        			_v2z = screenUVTs[uint(_index2*3 + 2)];
					_v0u = _uvs[0]._u;
		            _v0v = _uvs[0]._v;
		            _v1u = _uvs[1]._u;
		            _v1v = _uvs[1]._v;
		            _v2u = _uvs[2]._u;
		            _v2v = _uvs[2]._v;
		            
		            if ((_v0x == x) && (_v0y == y))
		                return new Vector3D(_v0u, _v0v, _v0z);
					
		            if ((_v1x == x) && (_v1y == y))
		                return new Vector3D(_v1u, _v1v, _v1z);
					
		            if ((_v2x == x) && (_v2y == y))
		                return new Vector3D(_v2u, _v2v, _v2z);
					
					_ax = (_v0x - x)/_v0z;
		            _bx = (_v1x - x)/_v1z;
		            _cx = (_v2x - x)/_v2z;
		            _ay = (_v0y - y)/_v0z;
		            _by = (_v1y - y)/_v1z;
		            _cy = (_v2y - y)/_v2z;
	            
		            _det = _ax*(_by - _cy) + _bx*(_cy - _ay) + _cx*(_ay - _by);
		            _da = x*(_by - _cy) + _bx*(_cy - y) + _cx*(y- _by);
		            _db = _ax*(y - _cy) + x*(_cy - _ay) + _cx*(_ay - y);
		            _dc = _ax*(_by - y) + _bx*(y - _ay) + x*(_ay - _by);
					
		            return new Vector3D((_da*_v0u + _db*_v1u + _dc*_v2u)/_det, (_da*_v0v + _db*_v1v + _dc*_v2v)/_det, _det/(_da/_v0z + _db/_v1z + _dc/_v2z));
		            
        		case PrimitiveType.SEGMENT:
		            
		            _index0 = screenIndices[_startIndex];
		            _v0x = screenVertices[uint(_index0*2)];
        			_v0y = screenVertices[uint(_index0*2 + 1)];
        			_v0z = screenUVTs[uint(_index0*3 + 2)];
        			_index1 = screenIndices[uint(_startIndex + 1)];
        			_v1x = screenVertices[uint(_index1*2)];
        			_v1y = screenVertices[uint(_index1*2 + 1)];
        			_v1z = screenUVTs[uint(_index1*3 + 2)];
					
		            if ((_v0x == x) && (_v0y == y))
		                return new Vector3D(0, 0, _v0z);
					
		            if ((_v1x == x) && (_v1y == y))
		                return new Vector3D(0, 0, _v1z);
					
		            _dx = _v1x - _v0x;
		            _dy = _v1y - _v0y;
					
		            _ax = (_v0x - x)/_v0z;
		            _bx = (_v1x - x)/_v1z;
		            _ay = (_v0y - y)/_v0z;
		            _by = (_v1y - y)/_v1z;
		
		            _det = _dx*(_ax - _bx) + _dy*(_ay - _by);
		            _db = _dx*(_ax - x) + _dy*(_ay - y);
		            _da = _dx*(x - _bx) + _dy*(y - _by);
					
            		return new Vector3D(0, 0, (_da/_v0z + _db/_v1z) / _det);
            		
        		case PrimitiveType.SPRITE3D:
		            return new Vector3D(0, 0, renderer.primitiveScreenZ[priIndex]);
        		case PrimitiveType.DISPLAY_OBJECT:
					return new Vector3D(0, 0, renderer.primitiveScreenZ[priIndex]);
				default:
					return new Vector3D(0,0,0);
			}
        }
        
        public function getArea(startIndex:uint):Number
        {
            _index = screenIndices[startIndex]*2;
        	_sv0x = screenVertices[_index];
        	_sv0y = screenVertices[uint(_index+1)];
        	
            _index = screenIndices[uint(startIndex+1)]*2;
        	_sv1x = screenVertices[_index];
        	_sv1y = screenVertices[uint(_index+1)];
        	
            _index = screenIndices[uint(startIndex+2)]*2;
        	_sv2x = screenVertices[_index];
        	_sv2y = screenVertices[uint(_index+1)];
        	
            return (_sv0x*(_sv2y - _sv1y) + _sv1x*(_sv0y - _sv2y) + _sv2x*(_sv1y - _sv0y));
        }
        
        public function quarter(priIndex:uint, renderer:Renderer):Array
        {
        	_startIndex = renderer.primitiveProperties[uint(priIndex*9)];
        	
        	switch (renderer.primitiveType[priIndex]) {
        		case PrimitiveType.FACE:
        			
		        	var area:Number = renderer.primitiveProperties[uint(priIndex*9 + 8)];
					if (area > -20 && area < 20)
		                return null;
		            
					_vertexIndex = screenVertices.length/2;
					
					_index0 = screenIndices.length;
		        	screenIndices[screenIndices.length] = screenIndices[_startIndex];
		        	screenIndices[screenIndices.length] = _vertexIndex;
		        	screenIndices[screenIndices.length] = _vertexIndex+2;
		        	_index1 = screenIndices.length;
		        	screenIndices[screenIndices.length] = screenIndices[uint(_startIndex+1)];
		        	screenIndices[screenIndices.length] = _vertexIndex+1;
		        	screenIndices[screenIndices.length] = _vertexIndex;
		        	_index2 = screenIndices.length;
		        	screenIndices[screenIndices.length] = screenIndices[uint(_startIndex+2)];
		        	screenIndices[screenIndices.length] = _vertexIndex+2;
		        	screenIndices[screenIndices.length] = _vertexIndex+1;
		        	_index3 = screenIndices.length;
		        	screenIndices[screenIndices.length] = _vertexIndex;
		        	screenIndices[screenIndices.length] = _vertexIndex+1;
		        	screenIndices[screenIndices.length] = _vertexIndex+2;
		        	_index4 = screenIndices.length;
		        	
		        	getMedian(_startIndex, _startIndex+1);
		        	getMedian(_startIndex+1, _startIndex+2);
		        	getMedian(_startIndex+2, _startIndex);
		        	
		        	_faceVO = renderer.primitiveElements[priIndex] as FaceVO;
		        	_material = renderer.primitiveMaterials[priIndex];
		        	_uvs = renderer.primitiveUVs[priIndex];
		        	var uv0:UV = _uvs[0];
		        	var uv1:UV = _uvs[1];
		        	var uv2:UV = _uvs[2];
					var uv01:UV = UV.median(uv0, uv1);
		            var uv12:UV = UV.median(uv1, uv2);
		            var uv20:UV = UV.median(uv2, uv0);
					
					_priLength = renderer.primitiveType.length;
					renderer.createDrawTriangle(_faceVO, faceCommands, Vector.<UV>([uv0, uv01, uv20]), _material, _index0, _index1, this, getArea(_index0), true);
					renderer.createDrawTriangle(_faceVO, faceCommands, Vector.<UV>([uv1, uv12, uv01]), _material, _index1, _index2, this, getArea(_index1), true);
					renderer.createDrawTriangle(_faceVO, faceCommands, Vector.<UV>([uv2, uv20, uv12]), _material, _index2, _index3, this, getArea(_index2), true);
					renderer.createDrawTriangle(_faceVO, faceCommands, Vector.<UV>([uv01, uv12, uv20]), _material, _index3, _index4, this, getArea(_index3), true);
	            	
	            	return [_priLength, _priLength + 1, _priLength + 2, _priLength + 3];
	            	
	            case PrimitiveType.SEGMENT:
	            
	            	var length:Number = renderer.primitiveProperties[uint(priIndex*9 + 8)];
	            	if (length < 5)
		                return null;
					
					_vertexIndex = screenVertices.length/2;
					
					_index0 = screenIndices.length;
		        	screenIndices[screenIndices.length] = screenIndices[_startIndex];
		        	screenIndices[screenIndices.length] = _vertexIndex;
		        	_index1 = screenIndices.length;
		        	screenIndices[screenIndices.length] = _vertexIndex;
		        	screenIndices[screenIndices.length] = screenIndices[uint(_startIndex+1)];
		        	_index2 = screenIndices.length;
		        	
		        	getMedian(_startIndex, _startIndex+1);
		        	
					_segmentVO = renderer.primitiveElements[priIndex] as SegmentVO;
		        	_material = renderer.primitiveMaterials[priIndex];
		        	
					_priLength = renderer.primitiveType.length;
					renderer.createDrawSegment(_segmentVO, segmentCommands, _material, _index0, _index1, this, true);
					renderer.createDrawSegment(_segmentVO, segmentCommands, _material, _index1, _index2, this, true);
                	
	            	return [_priLength, _priLength + 1];
	            	
        		case PrimitiveType.SPRITE3D:
		            return [priIndex];
				case PrimitiveType.DISPLAY_OBJECT:
					return [priIndex];
				default:
					return[priIndex];
        	}
        }
        
        public function fivepointcut(priIndex:uint, renderer:Renderer, i0:Number, v01x:Number, v01y:Number, v01z:Number, i1:Number, v12x:Number, v12y:Number, v12z:Number, i2:Number, uv0:UV, uv01:UV, uv1:UV, uv12:UV, uv2:UV):Array
        {
        	var vertexIndex:int = screenVertices.length/2;
        	var v0:int = screenIndices[i0];
        	var v1:int = screenIndices[i1];
        	var v2:int = screenIndices[i2];
        	var lens:AbstractLens = renderer._view.camera.lens;
        	
        	_faceVO = renderer.primitiveElements[priIndex] as FaceVO;
		    _material = renderer.primitiveMaterials[priIndex];
		    
            if (distanceSqr(screenVertices[uint(v0*2)], screenVertices[uint(v0*2+1)], v12x, v12y) < distanceSqr(v01x, v01y, screenVertices[uint(v2*2)], screenVertices[uint(v2*2+1)])) {
            	_index0 = screenIndices.length;
	        	screenIndices[screenIndices.length] = v0;
	        	screenIndices[screenIndices.length] = vertexIndex;
	        	screenIndices[screenIndices.length] = vertexIndex+1;
	        	_index1 = screenIndices.length;
	        	screenIndices[screenIndices.length] = vertexIndex;
	        	screenIndices[screenIndices.length] = v1;
	        	screenIndices[screenIndices.length] = vertexIndex+1;
	        	_index2 = screenIndices.length;
	        	screenIndices[screenIndices.length] = v0;
	        	screenIndices[screenIndices.length] = vertexIndex+1;
	        	screenIndices[screenIndices.length] = v2;
	        	_index3 = screenIndices.length;
	        	
	        	screenVertices[screenVertices.length] = v01x;
				screenVertices[screenVertices.length] = v01y;
				screenUVTs.push(0, 0, lens.getT(v01z));
				
	        	screenVertices[screenVertices.length] = v12x;
				screenVertices[screenVertices.length] = v12y;
				screenUVTs.push(0, 0, lens.getT(v12z));
		        
				_priLength = renderer.primitiveType.length;
				renderer.createDrawTriangle(_faceVO, faceCommands, Vector.<UV>([uv0, uv01, uv12]), _material, _index0, _index1, this, getArea(_index0), true);
				renderer.createDrawTriangle(_faceVO, faceCommands, Vector.<UV>([uv01, uv1, uv12]), _material, _index1, _index2, this, getArea(_index1), true);
				renderer.createDrawTriangle(_faceVO, faceCommands, Vector.<UV>([uv0, uv12, uv2]), _material, _index2, _index3, this, getArea(_index2), true);
	            
            } else {
            	_index0 = screenIndices.length;
	        	screenIndices[screenIndices.length] = v0;
	        	screenIndices[screenIndices.length] = vertexIndex;
	        	screenIndices[screenIndices.length] = v2;
	        	_index1 = screenIndices.length;
	        	screenIndices[screenIndices.length] = vertexIndex;
	        	screenIndices[screenIndices.length] = v1;
	        	screenIndices[screenIndices.length] = vertexIndex+1;
	        	_index2 = screenIndices.length;
	        	screenIndices[screenIndices.length] = vertexIndex;
	        	screenIndices[screenIndices.length] = vertexIndex+1;
	        	screenIndices[screenIndices.length] = v2;
	        	_index3 = screenIndices.length;
	        	
	        	screenVertices[screenVertices.length] = v01x;
				screenVertices[screenVertices.length] = v01y;
				screenUVTs.push(0, 0, lens.getT(v01z));
				
	        	screenVertices[screenVertices.length] = v12x;
				screenVertices[screenVertices.length] = v12y;
				screenUVTs.push(0, 0, lens.getT(v12z));
	        	
				_priLength = renderer.primitiveType.length;
				renderer.createDrawTriangle(_faceVO, faceCommands, Vector.<UV>([uv0, uv01, uv2]), _material, _index0, _index1, this, getArea(_index0), true);
				renderer.createDrawTriangle(_faceVO, faceCommands, Vector.<UV>([uv01, uv1, uv12]), _material, _index1, _index2, this, getArea(_index1), true);
				renderer.createDrawTriangle(_faceVO, faceCommands, Vector.<UV>([uv01, uv12, uv2]), _material, _index2, _index3, this, getArea(_index2), true);
            }
            
            return [_priLength, _priLength + 1, _priLength + 2];
        }
        
        public function onepointcut(priIndex:uint, renderer:Renderer, v01x:Number, v01y:Number, v01z:Number):Array
		{
			_startIndex = renderer.primitiveProperties[uint(priIndex*9)];
			
			_index0 = screenIndices.length;
        	screenIndices[screenIndices.length] = screenIndices[_startIndex];
        	screenIndices[screenIndices.length] = screenVertices.length;
        	_index1 = screenIndices.length;
        	screenIndices[screenIndices.length] = screenVertices.length;
        	screenIndices[screenIndices.length] = screenIndices[uint(_startIndex+1)];
        	_index2 = screenIndices.length;
        	
        	screenVertices[screenVertices.length] = v01x;
			screenVertices[screenVertices.length] = v01y;
			screenUVTs.push(0, 0, v01z);
			
			_segmentVO = renderer.primitiveElements[priIndex] as SegmentVO;
		    _material = renderer.primitiveMaterials[priIndex];
		    
			_priLength = renderer.primitiveType.length;
			renderer.createDrawSegment(_segmentVO, segmentCommands, _material, _index0, _index1, this, true);
			renderer.createDrawSegment(_segmentVO, segmentCommands, _material, _index1, _index2, this, true);
	        
	        return [_priLength, _priLength + 1];
    	}
	}
}
