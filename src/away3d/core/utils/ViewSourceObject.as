package away3d.core.utils 
{
	import away3d.core.project.PrimitiveType;
	import away3d.core.vos.FaceVO;
	import away3d.core.vos.SegmentVO;
	import away3d.core.vos.SpriteVO;
	import away3d.core.draw.ScreenVertex;
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.geom.*;
	import away3d.core.render.*;
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
		
        private var _azf:Number;
        private var _bzf:Number;
        private var _czf:Number;
		
        private var _faz:Number;
        private var _fbz:Number;
        private var _fcz:Number;
		
		private var _dx:Number;
		private var _dy:Number;
        private var _axf:Number;
        private var _bxf:Number;
        private var _cxf:Number;
        private var _ayf:Number;
        private var _byf:Number;
        private var _cyf:Number;
		
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
        
        private var _focus:Number;
        private var _startIndex:Number;
        private var _endIndex:Number;
        private var _faceVO:FaceVO;
        private var _segmentVO:SegmentVO;
        private var _material:Material;
        private var _index0:int;
        private var _index1:int;
        private var _index2:int;
        private var _index3:int;
        private var _index4:int;
        private var _uvs:Array;
        private var _priLength:uint;
        
		public var source:Object3D;
		public var screenVertices:Array;
		public var screenIndices:Array;
		
		public function ViewSourceObject(source:Object3D)
		{
			this.source = source;
		}
		
		        
        public function contains(priIndex:uint, renderer:Renderer, x:Number, y:Number):Boolean
        {
        	_focus = renderer._view.camera.focus;
			_startIndex = renderer.primitiveProperties[priIndex*9];
			
			switch (renderer.primitiveType[priIndex]) {
        		case PrimitiveType.FACE:
					_endIndex = renderer.primitiveProperties[priIndex*9 + 1];
        			//use crossing count on an infinite ray projected from the test point along the x axis
	        		var c:Boolean = false;
	        		var i:int = _startIndex;
	        		var j:int = _endIndex - 1;
	        		var vertix:Number;
	        		var vertiy:Number;
	        		var vertjx:Number;
	        		var vertjy:Number;
	        		var iIndex:int;
	        		var jIndex:int;
	        		
	        		_faceVO = renderer.primitiveElements[priIndex] as FaceVO;
					while (i < _endIndex) {
						if (_faceVO.commands[i - _startIndex] == PathCommand.CURVE)
							i++;
						
						if ((((vertiy = screenVertices[(iIndex = screenIndices[i]*3) + 1]) > y) != ((vertjy = screenVertices[(jIndex = screenIndices[j]*3) + 1]) > y)) && (x < ((vertjx = screenVertices[jIndex]) - (vertix = screenVertices[iIndex]))*(y - vertiy)/(vertjy - vertiy) + vertix))
							c = !c;
						
						j = i++;
						
						if (_faceVO.commands[i - _startIndex] == PathCommand.MOVE)
							j = i++;
					}
					return c;
					
        		case PrimitiveType.SEGMENT:
        			_v0x = screenVertices[screenIndices[_startIndex]*3];
        			_v0y = screenVertices[screenIndices[_startIndex]*3 + 1];
        			_v1x = screenVertices[screenIndices[_startIndex + 1]*3];
        			_v1y = screenVertices[screenIndices[_startIndex + 1]*3 + 1];
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
		            var scale:Number = renderer.primitiveProperties[priIndex*9 + 8];
					var spriteVO:SpriteVO = renderer.primitiveElements[priIndex] as SpriteVO;
					var pointMapping:Matrix = spriteVO.mapping.clone();
					var bMaterial:BitmapMaterial;
					if ((bMaterial = spriteVO.material as BitmapMaterial)) {
			            pointMapping.scale(scale*bMaterial.width, scale*bMaterial.height);
					} else {
			            pointMapping.scale(scale*spriteVO.width, scale*spriteVO.height);
					}
					
		            pointMapping.translate(screenVertices[screenIndices[_startIndex]*3], screenVertices[screenIndices[_startIndex]*3 + 1]);
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
        
        public function getUVT(priIndex:uint, renderer:Renderer, x:Number, y:Number):Array
        {
        	_focus = renderer._view.camera.focus;
        	_startIndex = renderer.primitiveProperties[priIndex*9];
        	
        	switch (renderer.primitiveType[priIndex]) {
        		case PrimitiveType.FACE:
					_endIndex = renderer.primitiveProperties[priIndex*9 + 1];
					
					if (_endIndex - _startIndex > 3)
						return [0, 0, renderer.primitiveScreenZ[priIndex]];
					
					_uvs = renderer.primitiveUVs[priIndex];
					_index0 = screenIndices[_startIndex]*3;
					_v0x = screenVertices[_index0];
        			_v0y = screenVertices[_index0 + 1];
        			_v0z = screenVertices[_index0 + 2];
        			_index1 = screenIndices[_startIndex + 1]*3;
        			_v1x = screenVertices[_index1];
        			_v1y = screenVertices[_index1 + 1];
        			_v1z = screenVertices[_index1 + 2];
        			_index2 = screenIndices[_startIndex + 2]*3;
        			_v2x = screenVertices[_index2];
        			_v2y = screenVertices[_index2 + 1];
        			_v2z = screenVertices[_index2 + 2];
					_v0u = _uvs[0]._u;
		            _v0v = _uvs[0]._v;
		            _v1u = _uvs[1]._u;
		            _v1v = _uvs[1]._v;
		            _v2u = _uvs[2]._u;
		            _v2v = _uvs[2]._v;
		            
		            if ((_v0x == x) && (_v0y == y))
		                return [_v0u, _v0v, _v0z];
					
		            if ((_v1x == x) && (_v1y == y))
		                return [_v1u, _v1v, _v1z];
					
		            if ((_v2x == x) && (_v2y == y))
		                return [_v2u, _v2v, _v2z];
					
		            _azf = _v0z / _focus;
		            _bzf = _v1z / _focus;
		            _czf = _v2z / _focus;
					
		            _faz = 1 + _azf;
		            _fbz = 1 + _bzf;
		            _fcz = 1 + _czf;
					
		            _axf = _v0x*_faz - x*_azf;
		            _bxf = _v1x*_fbz - x*_bzf;
		            _cxf = _v2x*_fcz - x*_czf;
		            _ayf = _v0y*_faz - y*_azf;
		            _byf = _v1y*_fbz - y*_bzf;
		            _cyf = _v2y*_fcz - y*_czf;
					
		            _det = _axf*(_byf - _cyf) + _bxf*(_cyf - _ayf) + _cxf*(_ayf - _byf);
		            _da = x*(_byf - _cyf) + _bxf*(_cyf - y) + _cxf*(y - _byf);
		            _db = _axf*(y - _cyf) + x*(_cyf - _ayf) + _cxf*(_ayf - y);
		            _dc = _axf*(_byf - y) + _bxf*(y - _ayf) + x*(_ayf - _byf);
					
		            return [(_da*_v0u + _db*_v1u + _dc*_v2u) / _det, (_da*_v0v + _db*_v1v + _dc*_v2v) / _det, (_da*_v0z + _db*_v1z + _dc*_v2z) / _det];
		            
        		case PrimitiveType.SEGMENT:
		            
		            _index0 = screenIndices[_startIndex]*3;
		            _v0x = screenVertices[_index0];
        			_v0y = screenVertices[_index0 + 1];
        			_v0z = screenVertices[_index0 + 2];
        			_index1 = screenIndices[_startIndex + 1]*3;
        			_v1x = screenVertices[_index1];
        			_v1y = screenVertices[_index1 + 1];
        			_v1z = screenVertices[_index1 + 2];
					
		            if ((_v0x == x) && (_v0y == y))
		                return [0, 0, _v0z];
					
		            if ((_v1x == x) && (_v1y == y))
		                return [0, 0, _v1z];
					
		            _dx = _v1x - _v0x;
		            _dy = _v1y - _v0y;
					
		            _azf = _v0z / _focus;
		            _bzf = _v1z / _focus;
					
		            _faz = 1 + _azf;
		            _fbz = 1 + _bzf;
					
		            _axf = _v0x*_faz - x*_azf;
		            _bxf = _v1x*_fbz - x*_bzf;
		            _ayf = _v0y*_faz - y*_azf;
		            _byf = _v1y*_fbz - y*_bzf;
		
		            _det = _dx*(_axf - _bxf) + _dy*(_ayf - _byf);
		            _db = _dx*(_axf - x) + _dy*(_ayf - y);
		            _da = _dx*(x - _bxf) + _dy*(y - _byf);
					
            		return [0, 0, (_da*_v0z + _db*_v1z) / _det];
            		
        		case PrimitiveType.SPRITE3D:
		            return [0, 0, renderer.primitiveScreenZ[priIndex]];
        		case PrimitiveType.DISPLAY_OBJECT:
					return [0, 0, renderer.primitiveScreenZ[priIndex]];
				default:
					return[0,0,0];
			}
        }
        
        public function getArea(startIndex:uint):Number
        {
            _index = screenIndices[startIndex]*3;
        	_sv0x = screenVertices[_index];
        	_sv0y = screenVertices[_index+1];
        	
            _index = screenIndices[startIndex+1]*3;
        	_sv1x = screenVertices[_index];
        	_sv1y = screenVertices[_index+1];
        	
            _index = screenIndices[startIndex+2]*3;
        	_sv2x = screenVertices[_index];
        	_sv2y = screenVertices[_index+1];
        	
            return (_sv0x*(_sv2y - _sv1y) + _sv1x*(_sv0y - _sv2y) + _sv2x*(_sv1y - _sv0y));
        }
        
        public function quarter(priIndex:uint, renderer:Renderer):Array
        {
        	_focus = renderer._view.camera.focus;
        	_startIndex = renderer.primitiveProperties[priIndex*9];
        	
        	switch (renderer.primitiveType[priIndex]) {
        		case PrimitiveType.FACE:
        			
		        	var area:Number = renderer.primitiveProperties[priIndex*9 + 8];
					if (area > -20 && area < 20)
		                return null;
		            
					var vertexIndex:int = screenVertices.length/3;
					
					_index0 = screenIndices.length;
		        	screenIndices[screenIndices.length] = screenIndices[_startIndex];
		        	screenIndices[screenIndices.length] = vertexIndex;
		        	screenIndices[screenIndices.length] = vertexIndex+2;
		        	_index1 = screenIndices.length;
		        	screenIndices[screenIndices.length] = screenIndices[_startIndex+1];
		        	screenIndices[screenIndices.length] = vertexIndex+1;
		        	screenIndices[screenIndices.length] = vertexIndex;
		        	_index2 = screenIndices.length;
		        	screenIndices[screenIndices.length] = screenIndices[_startIndex+2];
		        	screenIndices[screenIndices.length] = vertexIndex+2;
		        	screenIndices[screenIndices.length] = vertexIndex+1;
		        	_index3 = screenIndices.length;
		        	screenIndices[screenIndices.length] = vertexIndex;
		        	screenIndices[screenIndices.length] = vertexIndex+1;
		        	screenIndices[screenIndices.length] = vertexIndex+2;
		        	_index4 = screenIndices.length;
		        	
		        	ScreenVertex.median(_startIndex, _startIndex+1, screenVertices, screenIndices, _focus);
		        	ScreenVertex.median(_startIndex+1, _startIndex+2, screenVertices, screenIndices, _focus);
		        	ScreenVertex.median(_startIndex+2, _startIndex, screenVertices, screenIndices, _focus);
		        	
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
					renderer.createDrawTriangle(_faceVO, ["M", "L", "L"], [uv0,  uv01, uv20], _material, _index0, _index1, this, getArea(_index0), true);
	                renderer.createDrawTriangle(_faceVO, ["M", "L", "L"], [uv1,  uv12, uv01], _material, _index1, _index2, this, getArea(_index1), true);
	                renderer.createDrawTriangle(_faceVO, ["M", "L", "L"], [uv2,  uv20, uv12], _material, _index2, _index3, this, getArea(_index2), true);
	                renderer.createDrawTriangle(_faceVO, ["M", "L", "L"], [uv01, uv12, uv20], _material, _index3, _index4, this, getArea(_index3), true);
	            	
	            	return [_priLength, _priLength + 1, _priLength + 2, _priLength + 3];
	            	
	            case PrimitiveType.SEGMENT:
	            
	            	var length:Number = renderer.primitiveProperties[priIndex*9 + 8];
	            	if (length < 5)
		                return null;
					
					_index0 = screenIndices.length;
		        	screenIndices[screenIndices.length] = screenIndices[_startIndex];
		        	screenIndices[screenIndices.length] = screenVertices.length;
		        	_index1 = screenIndices.length;
		        	screenIndices[screenIndices.length] = screenVertices.length;
		        	screenIndices[screenIndices.length] = screenIndices[_startIndex+1];
		        	_index2 = screenIndices.length;
		        	
		        	ScreenVertex.median(_startIndex, _startIndex+1, screenVertices, screenIndices, _focus);
		        	
					_segmentVO = renderer.primitiveElements[priIndex] as SegmentVO;
		        	_material = renderer.primitiveMaterials[priIndex];
		        	
		        	_priLength = renderer.primitiveType.length;
	                renderer.createDrawSegment(_segmentVO, ["M", "L"], _material, _index0, _index1, this, true);
	                renderer.createDrawSegment(_segmentVO, ["M", "L"], _material, _index1, _index2, this, true);
                	
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
        	var vertexIndex:int = screenVertices.length/3;
        	var v0:int = screenIndices[i0];
        	var v1:int = screenIndices[i1];
        	var v2:int = screenIndices[i2];
        	
        	_faceVO = renderer.primitiveElements[priIndex] as FaceVO;
		    _material = renderer.primitiveMaterials[priIndex];
		    
            if (ScreenVertex.distanceSqr(screenVertices[v0*3], screenVertices[v0*3+1], v12x, v12y) < ScreenVertex.distanceSqr(v01x, v01y, screenVertices[v2*3], screenVertices[v2*3+1])) {
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
				screenVertices[screenVertices.length] = v01z;
				
	        	screenVertices[screenVertices.length] = v12x;
				screenVertices[screenVertices.length] = v12y;
				screenVertices[screenVertices.length] = v12z;
		        
				_priLength = renderer.primitiveType.length;
	            renderer.createDrawTriangle(_faceVO, ["M", "L", "L"], [uv0,  uv01, uv12], _material, _index0, _index1, this, getArea(_index0), true);
	            renderer.createDrawTriangle(_faceVO, ["M", "L", "L"], [uv01,  uv1, uv12], _material, _index1, _index2, this, getArea(_index1), true);
	            renderer.createDrawTriangle(_faceVO, ["M", "L", "L"], [uv0,  uv12, uv2], _material, _index2, _index3, this, getArea(_index2), true);
	            
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
				screenVertices[screenVertices.length] = v01z;
				
	        	screenVertices[screenVertices.length] = v12x;
				screenVertices[screenVertices.length] = v12y;
				screenVertices[screenVertices.length] = v12z;
	        	
	        	_priLength = renderer.primitiveType.length;
	            renderer.createDrawTriangle(_faceVO, ["M", "L", "L"], [uv0,  uv01, uv2], _material, _index0, _index1, this, getArea(_index0), true);
	            renderer.createDrawTriangle(_faceVO, ["M", "L", "L"], [uv01,  uv1, uv12], _material, _index1, _index2, this, getArea(_index1), true);
	            renderer.createDrawTriangle(_faceVO, ["M", "L", "L"], [uv01,  uv12, uv2], _material, _index2, _index3, this, getArea(_index2), true);
            }
            
            return [_priLength, _priLength + 1, _priLength + 2];
        }
        
        public function onepointcut(priIndex:uint, renderer:Renderer, v01x:Number, v01y:Number, v01z:Number):Array
		{
			_startIndex = renderer.primitiveProperties[priIndex*9];
			
			_index0 = screenIndices.length;
        	screenIndices[screenIndices.length] = screenIndices[_startIndex];
        	screenIndices[screenIndices.length] = screenVertices.length;
        	_index1 = screenIndices.length;
        	screenIndices[screenIndices.length] = screenVertices.length;
        	screenIndices[screenIndices.length] = screenIndices[_startIndex+1];
        	_index2 = screenIndices.length;
        	
        	screenVertices[screenVertices.length] = v01x;
			screenVertices[screenVertices.length] = v01y;
			screenVertices[screenVertices.length] = v01z;
			
			_segmentVO = renderer.primitiveElements[priIndex] as SegmentVO;
		    _material = renderer.primitiveMaterials[priIndex];
		    
		    _priLength = renderer.primitiveType.length;
            renderer.createDrawSegment(_segmentVO, ["M", "L"], _material, _index0, _index1, this, true);
	        renderer.createDrawSegment(_segmentVO, ["M", "L"], _material, _index1, _index2, this, true);
	        
	        return [_priLength, _priLength + 1];
    	}
	}
}
