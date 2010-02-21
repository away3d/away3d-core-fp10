package away3d.materials
{
	import away3d.arcane;
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	use namespace arcane;
	
	/**
	 * Container for caching multiple bitmapmaterial objects.
	 * Renders each material by caching a bitmapData surface object for each face.
	 * For continually updating materials, use <code>CompositeMaterial</code>.
	 * 
	 * @see away3d.materials.CompositeMaterial
	 */
	public class CompositeMaterial extends BitmapMaterial implements ITriangleMaterial, ILayerMaterial
	{
		/** @private */
        arcane var _source:Object3D;
        
        private var _defaultColorTransform:ColorTransform = new ColorTransform();
		private var _uvt:Vector.<Number> = new Vector.<Number>(9, true);
		private var _width:Number;
		private var _height:Number;
		private var _surfaceCache:Boolean;
		private var _fMaterialVO:FaceMaterialVO;
		private var _containerDictionary:Dictionary = new Dictionary(true);
		private var _cacheDictionary:Dictionary = new Dictionary(true);
		private var _containerVO:FaceMaterialVO;
		private var _faceX:int;
		private var _faceY:int;
		private var _faceWidth:int;
		private var _faceHeight:int;
		private var _faceVO:FaceVO;
        private var _bRect:Rectangle;
        private var _u0:Number;
        private var _u1:Number;
        private var _u2:Number;
        private var _v0:Number;
        private var _v1:Number;
        private var _v2:Number;
        private var _invtexmapping:Matrix = new Matrix();
        
        private function onMaterialUpdate(event:MaterialEvent):void
        {
        	_materialDirty = true;
        }
        
        private function transformUV(faceVO:FaceVO):Matrix
        {
            
            if (faceVO.uv0 == null || faceVO.uv1 == null || faceVO.uv2 == null)
                return null;

            _u0 = _width * faceVO.uv0._u;
            _u1 = _width * faceVO.uv1._u;
            _u2 = _width * faceVO.uv2._u;
            _v0 = _height * (1 - faceVO.uv0._v);
            _v1 = _height * (1 - faceVO.uv1._v);
            _v2 = _height * (1 - faceVO.uv2._v);
      
            // Fix perpendicular projections
            if ((_u0 == _u1 && _v0 == _v1) || (_u0 == _u2 && _v0 == _v2)) {
            	if (_u0 > 0.05)
                	_u0 -= 0.05;
                else
                	_u0 += 0.05;
                	
                if (_v0 > 0.07)           
                	_v0 -= 0.07;
                else
                	_v0 += 0.07;
            }
    
            if (_u2 == _u1 && _v2 == _v1) {
            	if (_u2 > 0.04)
                	_u2 -= 0.04;
                else
                	_u2 += 0.04;
                	
                if (_v2 > 0.06)           
                	_v2 -= 0.06;
                else
                	_v2 += 0.06;
            }
            
        	_invtexmapping.a = _u1 - _u0;
        	_invtexmapping.b = _v1 - _v0;
        	_invtexmapping.c = _u2 - _u0;
        	_invtexmapping.d = _v2 - _v0;
            _invtexmapping.tx = _u0 - faceVO.face.bitmapRect.x;
            _invtexmapping.ty = _v0 - faceVO.face.bitmapRect.y;
            
            return _invtexmapping;
        }
        
		/**
		 * An array of bitmapmaterial objects to be overlayed sequentially.
		 */
		protected var materials:Array;
        
		/**
		 * @inheritDoc
		 */
		protected override function updateRenderBitmap():void
        {
        	_bitmapDirty = false;
        	
        	invalidateFaces();
        	
        	_materialDirty = true;
        }
        
		/**
		 * @inheritDoc
		 */
		protected override function getUVData(tri:DrawTriangle):Vector.<Number>
		{
			_faceVO = tri.faceVO.face.faceVO;
			
			if (_view.camera.lens is ZoomFocusLens)
        		_focus = tri.view.camera.focus;
        	else
        		_focus = 0;
			
			_faceMaterialVO = getFaceMaterialVO(_faceVO, tri.source, tri.view);
			
    		if (_faceMaterialVO.invalidated || _faceMaterialVO.updated) {
	    		_faceMaterialVO.updated = true;
	    		_faceMaterialVO.cleared = false;
	    		
	        	//check to see if face drawtriangle needs updating
	        	if (_faceMaterialVO.invalidated) {
	        		_faceMaterialVO.invalidated = false;
	        		
	        		//update face bitmapRect
	        		_faceVO.face.bitmapRect = new Rectangle(_faceX = int(_width*_faceVO.minU), _faceY = int(_height*(1 - _faceVO.maxV)), _faceWidth = int(_width*(_faceVO.maxU-_faceVO.minU)+2), _faceHeight = int(_height*(_faceVO.maxV-_faceVO.minV)+2));
	        		
	        		//update texturemapping
	        		_faceMaterialVO.uvtData[0] = (_faceVO.uv0.u*_width - _faceX)/_faceWidth;
		    		_faceMaterialVO.uvtData[1] = ((1 - _faceVO.uv0.v)*_height - _faceY)/_faceHeight;
					_faceMaterialVO.uvtData[3] = (_faceVO.uv1.u*_width - _faceX)/_faceWidth;
		    		_faceMaterialVO.uvtData[4] = ((1 - _faceVO.uv1.v)*_height - _faceY)/_faceHeight;
		    		_faceMaterialVO.uvtData[6] = (_faceVO.uv2.u*_width - _faceX)/_faceWidth;
		    		_faceMaterialVO.uvtData[7] = ((1 - _faceVO.uv2.v)*_height - _faceY)/_faceHeight;
	        		_faceMaterialVO.invtexturemapping = transformUV(_faceVO).clone();
	        		_faceMaterialVO.texturemapping = _faceMaterialVO.invtexturemapping.clone();
	        		_faceMaterialVO.texturemapping.invert();
	        		
	        		//resize bitmapData for container
	        		_faceMaterialVO.resize(_faceWidth, _faceHeight, transparent);
	        	}
        		
        		_fMaterialVO = _faceMaterialVO;
        		
	    		//call renderFace on each material
	    		for each (var _material:ILayerMaterial in materials)
	        		_fMaterialVO = _material.renderBitmapLayer(tri, _bitmapRect, _fMaterialVO);
        		
        		_cacheDictionary[_faceVO] = _fMaterialVO.bitmap;
	        	
	        	_fMaterialVO.updated = false;
			}
        	
        	_renderBitmap = _cacheDictionary[_faceVO];
        	
        	//check to see if tri is generated
        	if (tri.generated) {
        		_bRect = _faceVO.face.bitmapRect;
        		_faceX = _bRect.x;
        		_faceY = _bRect.y;
        		_faceWidth = _bRect.width;
        		_faceHeight = _bRect.height;
        		
        		//update texturemapping
        		_uvt[2] = 1/(_focus + tri.v0z);
				_uvt[5] = 1/(_focus + tri.v1z);
				_uvt[8] = 1/(_focus + tri.v2z);
        		_uvt[0] = (tri.uv0.u*_width - _faceX)/_faceWidth;
	    		_uvt[1] = ((1 - tri.uv0.v)*_height - _faceY)/_faceHeight;
				_uvt[3] = (tri.uv1.u*_width - _faceX)/_faceWidth;
	    		_uvt[4] = ((1 - tri.uv1.v)*_height - _faceY)/_faceHeight;
	    		_uvt[6] = (tri.uv2.u*_width - _faceX)/_faceWidth;
	    		_uvt[7] = ((1 - tri.uv2.v)*_height - _faceY)/_faceHeight;
	    		
	    		return _uvt;
        	}
        	
	        _faceMaterialVO.uvtData[2] = 1/(_focus + tri.v0z);
			_faceMaterialVO.uvtData[5] = 1/(_focus + tri.v1z);
			_faceMaterialVO.uvtData[8] = 1/(_focus + tri.v2z);
			
    		return _faceMaterialVO.uvtData;
        }
		
		/**
		 * Defines whether the caching bitmapData objects are transparent
		 */
		public var transparent:Boolean;
		
    	public function get surfaceCache():Boolean
        {
        	return _surfaceCache;
        }
        
        public function set surfaceCache(val:Boolean):void
        {
        	_surfaceCache = val;
        	
        	_materialDirty = true;
        }
        
		/**
		 * Creates a new <code>BitmapMaterialContainer</code> object.
		 * 
		 * @param	width				The containing width of the texture, applied to all child materials.
		 * @param	height				The containing height of the texture, applied to all child materials.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function CompositeMaterial(init:Object = null)
		{
            ini = Init.parse(init);
			
			_width = ini.getNumber("width", 128);
			_height = ini.getNumber("height", 128);
			
			super(new BitmapData(_width, _height, true, 0x00FFFFFF), ini);
			
			materials = ini.getArray("materials");
			
			_bitmapRect = new Rectangle(0, 0, _width, _height);
            
            for each (var _material:ILayerMaterial in materials)
            	_material.addOnMaterialUpdate(onMaterialUpdate);
			
			transparent = ini.getBoolean("transparent", true);
			_surfaceCache = ini.getBoolean("surfaceCache", false);
		}
		        
        public function addMaterial(material:ILayerMaterial):void
        {
        	material.addOnMaterialUpdate(onMaterialUpdate);
        	materials.push(material);
        	
        	_materialDirty = true;
        }
        
        public function removeMaterial(material:ILayerMaterial):void
        {
        	var index:int = materials.indexOf(material);
        	
        	if (index == -1)
        		return;
        	
        	material.removeOnMaterialUpdate(onMaterialUpdate);
        	
        	materials.splice(index, 1);
        	
        	_materialDirty = true;
        }
        
        public function clearMaterials():void
        {
        	var i:int = materials.length;
        	
        	while (i--)
        		removeMaterial(materials[i]);
        }
		
		/**
		 * Creates a new <code>BitmapMaterialContainer</code> object.
		 * 
		 * @param	width				The containing width of the texture, applied to all child materials.
		 * @param	height				The containing height of the texture, applied to all child materials.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public override function updateMaterial(source:Object3D, view:View3D):void
        {
        	for each (var _material:ILayerMaterial in materials)
        		_material.updateMaterial(source, view);
        	
        	if (_colorTransformDirty)
        		updateColorTransform();
        	
        	if (_bitmapDirty)
        		updateRenderBitmap();
        	
        	if (_materialDirty || _blendModeDirty)
        		updateFaces();
        	
        	_blendModeDirty = false;
        }
        
		/**
		 * @inheritDoc
		 */
		public override function renderTriangle(tri:DrawTriangle):void
        {
        	if (_surfaceCache) {
        		super.renderTriangle(tri);
        	} else {
	        	_source = tri.source;
	        	_session = _source.session;
	    		var level:int = 0;
	    		
	    		var _sprite:Sprite = _session.layer as Sprite;
	    		
	        	if (!_sprite || this != _session._material || _colorTransform || blendMode != BlendMode.NORMAL) {
	        		_sprite = _session.getSprite(this, level++);
	        		_sprite.blendMode = blendMode;
	        	}
	    		
	    		if (_colorTransform)
	    			_sprite.transform.colorTransform = _colorTransform;
	    		else
	    			_sprite.transform.colorTransform = _defaultColorTransform;
		        
	    		//call renderLayer on each material
	    		for each (var _material:ILayerMaterial in materials)
	        		level = _material.renderLayer(tri, _sprite, level);
        	}
        }
        
		/**
		 * @private
		 */
        public override function renderLayer(tri:DrawTriangle, layer:Sprite, level:int):int
        {
        	var _sprite:Sprite;
        	if (!_colorTransform && blendMode == BlendMode.NORMAL) {
        		_sprite = layer;
        	} else {
        		_source = tri.source;
        		_session = _source.session;
        		
        		_sprite = _session.getSprite(this, level++, layer);
	        	
	        	_sprite.blendMode = blendMode;
	        	
	    		if (_colorTransform)
	    			_sprite.transform.colorTransform = _colorTransform;
	    		else
	    			_sprite.transform.colorTransform = _defaultColorTransform;
        	}
    		
	    	//call renderLayer on each material
    		for each (var _material:ILayerMaterial in materials)
        		level = _material.renderLayer(tri, _sprite, level);
        	
        	return level;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function renderBitmapLayer(tri:DrawTriangle, containerRect:Rectangle, parentFaceMaterialVO:FaceMaterialVO):FaceMaterialVO
		{
			_faceMaterialVO = getFaceMaterialVO(tri.faceVO);
			
			//get width and height values
			_faceWidth = tri.faceVO.face.bitmapRect.width;
    		_faceHeight = tri.faceVO.face.bitmapRect.height;

			//check to see if bitmapContainer exists
			if (!(_containerVO = _containerDictionary[tri]))
				_containerVO = _containerDictionary[tri] = new FaceMaterialVO();
			
			//resize container
			if (parentFaceMaterialVO.resized) {
				parentFaceMaterialVO.resized = false;
				_containerVO.resize(_faceWidth, _faceHeight, transparent);
			}
			
			//call renderFace on each material
    		for each (var _material:ILayerMaterial in materials)
        		_containerVO = _material.renderBitmapLayer(tri, containerRect, _containerVO);
			
			//check to see if face update can be skipped
			if (parentFaceMaterialVO.updated || _containerVO.updated) {
				parentFaceMaterialVO.updated = false;
				_containerVO.updated = false;
				
				//reset booleans
				_faceMaterialVO.invalidated = false;
				_faceMaterialVO.cleared = false;
				_faceMaterialVO.updated = true;
        		
				//store a clone
				_faceMaterialVO.bitmap = parentFaceMaterialVO.bitmap.clone();
				_faceMaterialVO.bitmap.lock();
				
				_sourceVO = _faceMaterialVO;
	        	
	        	//draw into faceBitmap
	        	if (_blendMode == BlendMode.NORMAL && !_colorTransform)
	        		_faceMaterialVO.bitmap.copyPixels(_containerVO.bitmap, _containerVO.bitmap.rect, _zeroPoint, null, null, true);
	        	else
					_faceMaterialVO.bitmap.draw(_containerVO.bitmap, null, _colorTransform, _blendMode);
	  		}
	  		
	  		return _faceMaterialVO;        	
		}
	}
}