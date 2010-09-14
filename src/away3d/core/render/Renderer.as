package away3d.core.render
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
    import away3d.core.filter.*;
	import away3d.core.project.*;
	import away3d.core.session.*;
	import away3d.core.utils.*;
	import away3d.core.vos.*;
	import away3d.materials.*;
	
	import flash.geom.*;
	
	use namespace arcane;
	
    /**
    * A static class for an easy access to the most useful renderers.
    */
    public class Renderer
    {
    	/** @private */
        arcane var _primitives:Vector.<uint> = new Vector.<uint>();
        /** @private */
        arcane var _screenTs:Vector.<uint> = new Vector.<uint>();
        /** @private */
        arcane var _coeffScreenT:Number;
        /** @private */
        arcane var _order:Vector.<uint> = new Vector.<uint>();
    	/** @private */
		arcane var _view:View3D;
		/** @private */
		arcane var _session:AbstractSession;
		/** @private */
		arcane function renderPrimitive(priIndex:uint):void
		{
			_viewSourceObject = primitiveSource[priIndex];
			
			switch(primitiveType[priIndex]) {
				case PrimitiveType.DISPLAY_OBJECT :
					_spriteVO = primitiveElements[priIndex] as SpriteVO;
					_index = _viewSourceObject.screenIndices[uint(primitiveProperties[uint(priIndex*9)])]*2;
					_spriteVO.displayObject.x = _viewSourceObject.screenVertices[_index];
					_spriteVO.displayObject.y = _viewSourceObject.screenVertices[uint(_index + 1)];
					_spriteVO.displayObject.scaleX = _spriteVO.displayObject.scaleY = primitiveProperties[uint(priIndex*9 + 8)];
					_session.addDisplayObject(_spriteVO.displayObject);
					break;
				case PrimitiveType.FACE : 
					primitiveMaterials[priIndex].renderTriangle(priIndex, _viewSourceObject, this);
					break;
				case PrimitiveType.SEGMENT : 
					primitiveMaterials[priIndex].renderSegment(priIndex, _viewSourceObject, this);
					break;
				case PrimitiveType.SPRITE3D : 
					primitiveMaterials[priIndex].renderSprite(priIndex, _viewSourceObject, this);
					break;
				case PrimitiveType.FOG : 
					(primitiveMaterials[priIndex] as ColorMaterial).renderFog(priIndex, _viewSourceObject, this);
					break;
			}
		}
		
		private var _screenVertices:Vector.<Number>;
		private var _screenIndices:Vector.<int>;
		private var _screenUVTs:Vector.<Number>;
		private var _mesh:Mesh;
		
		private var _index:uint;
		private var _primitiveIndex:uint;
		private var _primitiveIndex9:uint;
        private var _vertex:int;
        private var _x:Number;
        private var _y:Number;
        private var _z:Number;
        private var _screenX:Number;
        private var _screenY:Number;
        private var _screenZ:Number;
        private var _minX:Number;
        private var _maxX:Number;
        private var _minY:Number;
        private var _maxY:Number;
        private var _minZ:Number;
        private var _maxZ:Number;
        private var _vertexCount:uint;
        
        /**
        * Fastest and simplest renderer, useful for many applications.
        * 
        * @see away3d.core.render.BasicRenderer
        */
        public static function get BASIC():Renderer
        {
            return new BasicRenderer();
        }
        
        /** Perform reordering of triangles after sorting to guarantee their correct rendering.
        * 
        * @see away3d.core.render.QuadrantRenderer
        * @see away3d.core.render.AnotherRivalFilter
        */
        public static function get CORRECT_Z_ORDER():Renderer
        {
            return new QuadrantRenderer(new AnotherRivalFilter());
        }

        /**
        * Perform triangles splitting to correctly render scenes with intersecting objects.
        * 
        * @see away3d.core.render.QuadrantRenderer
        * @see away3d.core.render.QuadrantRiddleFilter
        * @see away3d.core.render.AnotherRivalFilter
        */
        public static function get INTERSECTING_OBJECTS():Renderer
        {
            return new QuadrantRenderer(new QuadrantRiddleFilter(), new AnotherRivalFilter());
        }
        
        
        
        protected var _spriteVO:SpriteVO;
        protected var _viewSourceObject:ViewSourceObject;
        
        public var primitiveType:Vector.<uint> = new Vector.<uint>();
		public var primitiveScreenZ:Vector.<Number> = new Vector.<Number>();
		public var primitiveProperties:Vector.<Number> = new Vector.<Number>();
		public var primitiveElements:Vector.<ElementVO> = new Vector.<ElementVO>();
		public var primitiveSource:Vector.<ViewSourceObject> = new Vector.<ViewSourceObject>();
		public var primitiveCommands:Vector.<Array> = new Vector.<Array>();
		public var primitiveUVs:Vector.<Array> = new Vector.<Array>();
		public var primitiveMaterials:Vector.<Material> = new Vector.<Material>();
		public var primitiveGenerated:Vector.<Boolean> = new Vector.<Boolean>();
		
        public function clear():void
        {
        	primitiveType.length = 0;
			primitiveScreenZ.length = 0;
			primitiveProperties.length = 0;
			primitiveElements.length = 0;
			primitiveSource.length = 0;
			primitiveCommands.length = 0;
			primitiveUVs.length = 0;
			primitiveMaterials.length = 0;
			primitiveGenerated.length = 0;
        }
        
        public function primitive(priIndex:uint):Boolean
        {
        	throw new Error("Not implemented");
        }
        
        public function render():void
        {
        	throw new Error("Not implemented");
        }
        
        public function list():Vector.<uint>
        {
        	throw new Error("Not implemented");
        }
        
        public function clone():Renderer
        {
        	throw new Error("Not implemented");
        }
        
        public function toString():String
        {
            throw new Error("Not implemented");
        }
        
        
	    public function createDrawSprite(spriteVO:SpriteVO, material:Material, index:uint, viewSourceObject:ViewSourceObject, scale:Number):uint
	    {
	    	_primitiveIndex = primitiveType.length;
	    	_primitiveIndex9 = _primitiveIndex*9;
			_screenVertices = viewSourceObject.screenVertices;
			_screenIndices = viewSourceObject.screenIndices;
			_screenUVTs = viewSourceObject.screenUVTs;
	        
	        _vertex = _screenIndices[index];
        	_screenX = _screenVertices[uint(_vertex*2)];
        	_screenY = _screenVertices[uint(_vertex*2+1)];
        	_screenZ = _view.camera.lens.getScreenZ(_screenUVTs[uint(_vertex*3+2)]);
        	
            _minZ = _screenZ;
            _maxZ = _screenZ;
            
            var bMaterial:BitmapMaterial = material as BitmapMaterial;
            
            if (bMaterial) {
		        _minX = spriteVO.minX*scale*bMaterial.width + _screenX;
	        	_maxX = spriteVO.maxY*scale*bMaterial.width + _screenX;
	        	_minY = spriteVO.minY*scale*bMaterial.height + _screenY;
	        	_maxY = spriteVO.maxY*scale*bMaterial.height + _screenY;
            } else {
		        _minX = spriteVO.minX*scale*spriteVO.width + _screenX;
	        	_maxX = spriteVO.maxY*scale*spriteVO.width + _screenX;
	        	_minY = spriteVO.minY*scale*spriteVO.height + _screenY;
	        	_maxY = spriteVO.maxY*scale*spriteVO.height + _screenY;
            }
            
        	primitiveType[_primitiveIndex] = PrimitiveType.SPRITE3D;
        	primitiveScreenZ[_primitiveIndex] = _screenZ;
			primitiveProperties[_primitiveIndex9] = index;
        	primitiveProperties[uint(_primitiveIndex9 + 1)] = index;
        	primitiveProperties[uint(_primitiveIndex9 + 2)] = _minX;
        	primitiveProperties[uint(_primitiveIndex9 + 3)] = _maxX;
        	primitiveProperties[uint(_primitiveIndex9 + 4)] = _minY;
        	primitiveProperties[uint(_primitiveIndex9 + 5)] = _maxY;
        	primitiveProperties[uint(_primitiveIndex9 + 6)] = _minZ;
        	primitiveProperties[uint(_primitiveIndex9 + 7)] = _maxZ;
        	primitiveProperties[uint(_primitiveIndex9 + 8)] = scale;
			primitiveElements[_primitiveIndex] = spriteVO;
			primitiveSource[_primitiveIndex] = viewSourceObject;
			primitiveCommands[_primitiveIndex] = null;
			primitiveUVs[_primitiveIndex] = null;
			primitiveMaterials[_primitiveIndex] = material;
			primitiveGenerated[_primitiveIndex] = false;
			
	        return _primitiveIndex;
	    }
	    
	    public function createDrawSegment(segmentVO:SegmentVO, commands:Array, material:Material, startIndex:uint, endIndex:uint, viewSourceObject:ViewSourceObject, generated:Boolean = false):uint
	    {
	    	_primitiveIndex = primitiveType.length;
	    	_primitiveIndex9 = _primitiveIndex*9;
			_screenVertices = viewSourceObject.screenVertices;
			_screenIndices = viewSourceObject.screenIndices;
			_screenUVTs = viewSourceObject.screenUVTs;
			
			_mesh = viewSourceObject.source as Mesh;
			
			_vertexCount = endIndex - startIndex;
	        _screenZ = 0;
        	_index = endIndex;
        	_minX = Infinity;
        	_maxX = -Infinity;
        	_minY = Infinity;
        	_maxY = -Infinity;
        	_minZ = Infinity;
        	_maxZ = -Infinity;
        	while (_index-- > startIndex) {
        		_vertex = _screenIndices[_index];
            	//calculate bounding box
            	_x = _screenVertices[uint(_vertex*2)];
            	_y = _screenVertices[uint(_vertex*2+1)];
            	_z = _view.camera.lens.getScreenZ(_screenUVTs[uint(_vertex*3+2)]);
        		if (_minX > _x)
        			_minX = _x;
        		if (_maxX < _x)
        			_maxX = _x;
        		if (_minY > _y)
        			_minY = _y;
        		if (_maxY < _y)
        			_maxY = _y;
        		if (_minZ > _z)
        			_minZ = _z;
        		if (_maxZ < _z)
        			_maxZ = _z;
            	//calculate screenZ used for sorting
        		_screenZ += _z;
        	}
        	
            if (_mesh.pushfront)
                _screenZ = _minZ;
            else if (_mesh.pushback)
                _screenZ = _maxZ;
			else
	        	_screenZ /= _vertexCount;
			
			_screenZ += _mesh.screenZOffset;
	        	
        	primitiveType[_primitiveIndex] = PrimitiveType.SEGMENT;
        	primitiveScreenZ[_primitiveIndex] = _screenZ;
			primitiveProperties[_primitiveIndex9] = startIndex;
        	primitiveProperties[uint(_primitiveIndex9 + 1)] = endIndex;
        	primitiveProperties[uint(_primitiveIndex9 + 2)] = _minX;
        	primitiveProperties[uint(_primitiveIndex9 + 3)] = _maxX;
        	primitiveProperties[uint(_primitiveIndex9 + 4)] = _minY;
        	primitiveProperties[uint(_primitiveIndex9 + 5)] = _maxY;
        	primitiveProperties[uint(_primitiveIndex9 + 6)] = _minZ;
        	primitiveProperties[uint(_primitiveIndex9 + 7)] = _maxZ;
        	primitiveProperties[uint(_primitiveIndex9 + 8)] = Math.sqrt((_maxX - _minX)*(_maxX - _minX) + (_maxY - _minY)*(_maxY - _minY));
			primitiveElements[_primitiveIndex] = segmentVO;
			primitiveSource[_primitiveIndex] = viewSourceObject;
			primitiveCommands[_primitiveIndex] = commands;
			primitiveUVs[_primitiveIndex] = null;
			primitiveMaterials[_primitiveIndex] = material;
			primitiveGenerated[_primitiveIndex] = generated;
        	
			return _primitiveIndex;
	    }
	    
		public function createDrawTriangle(faceVO:FaceVO, commands:Array, uvs:Array, material:Material, startIndex:uint, endIndex:uint, viewSourceObject:ViewSourceObject, area:Number = 0, generated:Boolean = false):uint
		{
			_primitiveIndex = primitiveType.length;
			_primitiveIndex9 = _primitiveIndex*9;
			_screenVertices = viewSourceObject.screenVertices;
			_screenIndices = viewSourceObject.screenIndices;
			_screenUVTs = viewSourceObject.screenUVTs;
			
			_mesh = viewSourceObject.source as Mesh;
			
			_vertexCount = endIndex - startIndex;
	    	_screenZ = 0;
        	_index = endIndex;
        	_minX = Infinity;
        	_maxX = -Infinity;
        	_minY = Infinity;
        	_maxY = -Infinity;
        	_minZ = Infinity;
        	_maxZ = -Infinity;
        	while (_index-- > startIndex) {
        		_vertex = _screenIndices[_index];
            	//calculate bounding box
            	_x = _screenVertices[uint(_vertex*2)];
            	_y = _screenVertices[uint(_vertex*2 + 1)];
            	_z = _view.camera.lens.getScreenZ(_screenUVTs[uint(_vertex*3 + 2)]);
        		if (_minX > _x)
        			_minX = _x;
        		if (_maxX < _x)
        			_maxX = _x;
        		if (_minY > _y)
        			_minY = _y;
        		if (_maxY < _y)
        			_maxY = _y;
        		if (_minZ > _z)
        			_minZ = _z;
        		if (_maxZ < _z)
        			_maxZ = _z;
            	//calculate screenZ used for sorting
        		_screenZ += _z;
        	}
        	
            if (_mesh.pushfront)
                _screenZ = _minZ;
            else if (_mesh.pushback)
                _screenZ = _maxZ;
			else
	        	_screenZ /= _vertexCount;
			
			_screenZ += _mesh.screenZOffset;
			
        	primitiveType[_primitiveIndex] = PrimitiveType.FACE;
        	primitiveScreenZ[_primitiveIndex] = _screenZ;
        	primitiveProperties[_primitiveIndex9] = startIndex;
        	primitiveProperties[uint(_primitiveIndex9 + 1)] = endIndex;
        	primitiveProperties[uint(_primitiveIndex9 + 2)] = _minX;
        	primitiveProperties[uint(_primitiveIndex9 + 3)] = _maxX;
        	primitiveProperties[uint(_primitiveIndex9 + 4)] = _minY;
        	primitiveProperties[uint(_primitiveIndex9 + 5)] = _maxY;
        	primitiveProperties[uint(_primitiveIndex9 + 6)] = _minZ;
        	primitiveProperties[uint(_primitiveIndex9 + 7)] = _maxZ;
        	primitiveProperties[uint(_primitiveIndex9 + 8)] = area;
			primitiveElements[_primitiveIndex] = faceVO;
			primitiveSource[_primitiveIndex] = viewSourceObject;
			primitiveCommands[_primitiveIndex] = commands;
			primitiveUVs[_primitiveIndex] = uvs;
			primitiveMaterials[_primitiveIndex] = material;
			primitiveGenerated[_primitiveIndex] = generated;
        	
			return _primitiveIndex;
		}
		
	    public function createDrawDisplayObject(spriteVO:SpriteVO, index:uint, viewSourceObject:ViewSourceObject, scale:Number):uint
	    {
	    	_primitiveIndex = primitiveType.length;
	    	_primitiveIndex9 = _primitiveIndex*9;
			_screenVertices = viewSourceObject.screenVertices;
			_screenIndices = viewSourceObject.screenIndices;
			_screenUVTs = viewSourceObject.screenUVTs;
	        
	        _vertex = _screenIndices[index];
        	_screenX = _screenVertices[uint(_vertex*2)];
        	_screenY = _screenVertices[uint(_vertex*2+1)];
        	_screenZ = _view.camera.lens.getScreenZ(_screenUVTs[uint(_vertex*3+2)]);
        	
            _minZ = _screenZ;
            _maxZ = _screenZ;
            //check to see if displayobject is a session container
            var isContainer:Boolean = false;
            if (viewSourceObject.source) {
	            for each(var s:AbstractSession in viewSourceObject.source.session.sessions)
	            	if (s.getContainer(_view) == spriteVO.displayObject)
	            		isContainer = true;
            } else {
            	isContainer = true;
            }
            
            if (isContainer) {
            	_minX = -Infinity;
            	_minY = -Infinity;
            	_maxX = Infinity;
            	_maxY = Infinity;
            } else {
            	var displayRect:Rectangle = spriteVO.displayObject.getBounds(spriteVO.displayObject);
            	_minX = _screenX + displayRect.left;
            	_minY = _screenY + displayRect.top;
            	_maxX = _screenX + displayRect.right;
            	_maxY = _screenY + displayRect.bottom;
            }
            
	        primitiveType[_primitiveIndex] = PrimitiveType.DISPLAY_OBJECT;
	        primitiveScreenZ[_primitiveIndex] = _screenZ;
			primitiveProperties[_primitiveIndex9] = index;
        	primitiveProperties[uint(_primitiveIndex9 + 1)] = index;
        	primitiveProperties[uint(_primitiveIndex9 + 2)] = _minX;
        	primitiveProperties[uint(_primitiveIndex9 + 3)] = _maxX;
        	primitiveProperties[uint(_primitiveIndex9 + 4)] = _minY;
        	primitiveProperties[uint(_primitiveIndex9 + 5)] = _maxY;
        	primitiveProperties[uint(_primitiveIndex9 + 6)] = _minZ;
        	primitiveProperties[uint(_primitiveIndex9 + 7)] = _maxZ;
        	primitiveProperties[uint(_primitiveIndex9 + 8)] = scale;
			primitiveElements[_primitiveIndex] = spriteVO;
			primitiveSource[_primitiveIndex] = viewSourceObject;
			primitiveCommands[_primitiveIndex] = null;
			primitiveUVs[_primitiveIndex] = null;
			primitiveMaterials[_primitiveIndex] = null;
			primitiveGenerated[_primitiveIndex] = false;
			
			return _primitiveIndex;
	    }
	    
	    public function createDrawFog(fogVO:FogVO, clip:Clipping):uint
	    {
	    	_primitiveIndex = primitiveType.length;
            _primitiveIndex9 = _primitiveIndex*9;
            
	        primitiveType[_primitiveIndex] = PrimitiveType.FOG;
			primitiveScreenZ[_primitiveIndex] = fogVO.screenZ;
			primitiveProperties[_primitiveIndex9] = 0;
        	primitiveProperties[uint(_primitiveIndex9 + 1)] = 0;
        	primitiveProperties[uint(_primitiveIndex9 + 2)] = clip.minX;
        	primitiveProperties[uint(_primitiveIndex9 + 3)] = clip.maxX;
        	primitiveProperties[uint(_primitiveIndex9 + 4)] = clip.minY;
        	primitiveProperties[uint(_primitiveIndex9 + 5)] = clip.maxY;
        	primitiveProperties[uint(_primitiveIndex9 + 6)] = 0;
        	primitiveProperties[uint(_primitiveIndex9 + 7)] = 0;
        	primitiveProperties[uint(_primitiveIndex9 + 8)] = 0;
			primitiveElements[_primitiveIndex] = fogVO;
			primitiveSource[_primitiveIndex] = null;
			primitiveCommands[_primitiveIndex] = null;
			primitiveUVs[_primitiveIndex] = null;
			primitiveMaterials[_primitiveIndex] = fogVO.material;
			primitiveGenerated[_primitiveIndex] = false;
			
			return _primitiveIndex;
	    }
    }

}
