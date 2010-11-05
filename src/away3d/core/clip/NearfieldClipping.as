package away3d.core.clip
{
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.geom.*;
	import away3d.core.render.*;
	import away3d.core.session.*;
	import away3d.core.vos.*;
	
	import flash.utils.*;
	
	use namespace arcane;
	
    /**
    * Rectangle clipping combined with nearfield clipping
    */
    public class NearfieldClipping extends Clipping
    {
    	private var _faceVOs:Vector.<FaceVO>;
    	private var _faceVO:FaceVO;
    	private var _v0C:VertexClassification;
    	private var _v1C:VertexClassification;
    	private var _v2C:VertexClassification;
    	private var _v0d:Number;
    	private var _v1d:Number;
    	private var _v2d:Number;
    	private var _v0w:Number;
    	private var _v1w:Number;
    	private var _v2w:Number;
    	private var _d:Number;
    	private var _session:AbstractSession;
    	private var _frustum:Frustum;
    	private var _processed:Dictionary;
    	private var _pass:Boolean;
		private var _plane:Plane3D;
		private var _v0:Vertex;
    	private var _v01:Vertex;
    	private var _v1:Vertex;
    	private var _v12:Vertex;
    	private var _v2:Vertex;
    	private var _v20:Vertex;
    	private var _uv0:UV;
    	private var _uv01:UV;
    	private var _uv1:UV;
    	private var _uv12:UV;
    	private var _uv2:UV;
    	private var _uv20:UV;
		
		public override function set objectCulling(val:Boolean):void
		{
			if (!val)
				throw new Error("objectCulling requires setting to true for NearfieldClipping");
			
			_objectCulling = val;
		}
		
        public function NearfieldClipping(init:Object = null)
        {
            super(init);
            
            objectCulling = ini.getBoolean("objectCulling", true);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function checkPrimitive(renderer:Renderer, priIndex:uint):Boolean
        {
        	var primitiveProperties:Vector.<Number> = renderer.primitiveProperties;
        	var index:uint = priIndex*9;
        	
            if (primitiveProperties[uint(index + 3)] < minX)
                return false;
            if (primitiveProperties[uint(index + 2)] > maxX)
                return false;
            if (primitiveProperties[uint(index + 5)] < minY)
                return false;
            if (primitiveProperties[uint(index + 4)] > maxY)
                return false;
			
            return true;
        }
        
		public override function checkElements(mesh:Mesh, clippedFaceVOs:Vector.<FaceVO>, clippedSegmentVOs:Vector.<SegmentVO>, clippedSpriteVOs:Vector.<SpriteVO>, clippedVertices:Vector.<Vertex>, clippedVerts:Vector.<Number>, clippedIndices:Vector.<int>, startIndices:Vector.<int>):void
		{
			clippedSegmentVOs; clippedSpriteVOs;
			
			_session = mesh.session;
			_frustum = _cameraVarsStore.frustumDictionary[mesh];
			_processed = new Dictionary();
            _faceVOs = mesh.geometry.faceVOs;
            
			for each (_faceVO in _faceVOs)
				processFaceVO(_faceVO, clippedFaceVOs, clippedVertices, clippedVerts, clippedIndices, startIndices);
			
	        startIndices[startIndices.length] = clippedIndices.length;
		}
		
		private function processFaceVO(faceVO:FaceVO, clippedFaceVOs:Vector.<FaceVO>, clippedVertices:Vector.<Vertex>, clippedVerts:Vector.<Number>, clippedIndices:Vector.<int>, startIndices:Vector.<int>):void
		{
			_pass = true;
			_v0 = faceVO.vertices[0];
    		_v1 = faceVO.vertices[1];
    		_v2 = faceVO.vertices[2];
    		
			_v0C = _cameraVarsStore.createVertexClassification(_v0);
			_v1C = _cameraVarsStore.createVertexClassification(_v1);
			_v2C = _cameraVarsStore.createVertexClassification(_v2);
			
			if (_v0C.plane || _v1C.plane || _v2C.plane) {
				if ((_plane = _v0C.plane)) {
					_v0d = _v0C.distance;
					_v1d = _v1C.getDistance(_plane);
					_v2d = _v2C.getDistance(_plane);
				} else if ((_plane = _v1C.plane)) {
					_v0d = _v0C.getDistance(_plane);
					_v1d = _v1C.distance;
					_v2d = _v2C.getDistance(_plane);
				} else if ((_plane = _v2C.plane)) {
					_v0d = _v0C.getDistance(_plane);
					_v1d = _v1C.getDistance(_plane);
					_v2d = _v2C.distance;
				}
			} else {
				_plane = _frustum.planes[Frustum.NEAR];
				_v0d = _v0C.getDistance(_plane);
				_v1d = _v1C.getDistance(_plane);
				_v2d = _v2C.getDistance(_plane);
			}
			
			if (_v0d < 0 && _v1d < 0 && _v2d < 0)
				return;
			
			if (_v0d < 0 || _v1d < 0 || _v2d < 0) {
				_pass = false;
			}
			
			if (_pass) {
				clippedFaceVOs[clippedFaceVOs.length] = faceVO;
				
				startIndices[startIndices.length] = clippedIndices.length;
        		
				if (!_processed[_v0]) {
                    clippedVertices[clippedVertices.length] = _v0;
                    clippedVerts.push(_v0.x, _v0.y, _v0.z);
                    clippedIndices[clippedIndices.length] = (_processed[_v0] = clippedVertices.length) - 1;
                } else {
                	clippedIndices[clippedIndices.length] = _processed[_v0] - 1;
                }
                if (!_processed[_v1]) {
                    clippedVertices[clippedVertices.length] = _v1;
                    clippedVerts.push(_v1.x, _v1.y, _v1.z);
                    clippedIndices[clippedIndices.length] = (_processed[_v1] = clippedVertices.length) - 1;
                } else {
                	clippedIndices[clippedIndices.length] = _processed[_v1] - 1;
                }
                if (!_processed[_v2]) {
                    clippedVertices[clippedVertices.length] = _v2;
                    clippedVerts.push(_v2.x, _v2.y, _v2.z);
                    clippedIndices[clippedIndices.length] = (_processed[_v2] = clippedVertices.length) - 1;
                } else {
                	clippedIndices[clippedIndices.length] = _processed[_v2] - 1;
                }
                
				return;
			}
			
			if (_v0d >= 0 && _v1d < 0) {
				_v0w = _v0d;
				_v1w = _v1d;
				_v2w = _v2d;
				_v0 = faceVO.vertices[0];
    			_v1 = faceVO.vertices[1];
    			_v2 = faceVO.vertices[2];
    			_uv0 = faceVO.uvs[0];
    			_uv1 = faceVO.uvs[1];
    			_uv2 = faceVO.uvs[2];
			} else if (_v1d >= 0 && _v2d < 0) {
				_v0w = _v1d;
				_v1w = _v2d;
				_v2w = _v0d;
				_v0 = faceVO.vertices[1];
    			_v1 = faceVO.vertices[2];
    			_v2 = faceVO.vertices[0];
    			_uv0 = faceVO.uvs[1];
    			_uv1 = faceVO.uvs[2];
    			_uv2 = faceVO.uvs[0];
			} else if (_v2d >= 0 && _v0d < 0) {
				_v0w = _v2d;
				_v1w = _v0d;
				_v2w = _v1d;
    			_v0 = faceVO.vertices[2];
    			_v1 = faceVO.vertices[0];
    			_v2 = faceVO.vertices[1];
    			_uv0 = faceVO.uvs[2];
    			_uv1 = faceVO.uvs[0];
    			_uv2 = faceVO.uvs[1];
			}
    		
        	_d = (_v0w - _v1w);
        	
        	_v01 = _cameraVarsStore.createVertex((_v1.x*_v0w - _v0.x*_v1w)/_d, (_v1.y*_v0w - _v0.y*_v1w)/_d, (_v1.z*_v0w - _v0.z*_v1w)/_d);
        	
        	_uv01 = _uv0? _cameraVarsStore.createUV((_uv1.u*_v0w - _uv0.u*_v1w)/_d, (_uv1.v*_v0w - _uv0.v*_v1w)/_d, _session) : null;
    		
        	if (_v2w < 0) {
	        	
				_d = (_v0w - _v2w);
				
        		_v20 = _cameraVarsStore.createVertex((_v2.x*_v0w - _v0.x*_v2w)/_d, (_v2.y*_v0w - _v0.y*_v2w)/_d, (_v2.z*_v0w - _v0.z*_v2w)/_d);
        		
        		_uv20 = _uv0? _cameraVarsStore.createUV((_uv2.u*_v0w - _uv0.u*_v2w)/_d, (_uv2.v*_v0w - _uv0.v*_v2w)/_d, _session) : null;
        		
        		var newFaceVO1:FaceVO = _cameraVarsStore.createFaceVO(faceVO.face, faceVO.material, faceVO.back);
        		newFaceVO1.vertices[0] = _v0;
        		newFaceVO1.vertices[1] = _v01;
        		newFaceVO1.vertices[2] = _v20;
        		newFaceVO1.uvs[0] = _uv0;
        		newFaceVO1.uvs[1] = _uv01;
        		newFaceVO1.uvs[2] = _uv20;
        		
        		processFaceVO(newFaceVO1, clippedFaceVOs, clippedVertices, clippedVerts, clippedIndices, startIndices);
        	} else {
        		_d = (_v2w - _v1w);
        		
        		_v12 = _cameraVarsStore.createVertex((_v1.x*_v2w - _v2.x*_v1w)/_d, (_v1.y*_v2w - _v2.y*_v1w)/_d, (_v1.z*_v2w - _v2.z*_v1w)/_d);
        		
        		_uv12 = _uv0? _cameraVarsStore.createUV((_uv1.u*_v2w - _uv2.u*_v1w)/_d, (_uv1.v*_v2w - _uv2.v*_v1w)/_d, _session) : null;
        		
        		var newFaceVO2:FaceVO = _cameraVarsStore.createFaceVO(faceVO.face, faceVO.material, faceVO.back);
        		newFaceVO2.vertices[0] = _v0;
        		newFaceVO2.vertices[1] = _v01;
        		newFaceVO2.vertices[2] = _v2;
        		newFaceVO2.uvs[0] = _uv0;
        		newFaceVO2.uvs[1] = _uv01;
        		newFaceVO2.uvs[2] = _uv2;
        		
        		var newFaceVO3:FaceVO = _cameraVarsStore.createFaceVO(faceVO.face, faceVO.material, faceVO.back);
        		newFaceVO3.vertices[0] = _v01;
        		newFaceVO3.vertices[1] = _v12;
        		newFaceVO3.vertices[2] = _v2;
        		newFaceVO3.uvs[0] = _uv01;
        		newFaceVO3.uvs[1] = _uv12;
        		newFaceVO3.uvs[2] = _uv2;
        		
        		processFaceVO(newFaceVO2, clippedFaceVOs, clippedVertices, clippedVerts, clippedIndices, startIndices);
        		processFaceVO(newFaceVO3, clippedFaceVOs, clippedVertices, clippedVerts, clippedIndices, startIndices);
        	}
    	}
    	
		/**
		 * @inheritDoc
		 */
        public override function rect(minX:Number, minY:Number, maxX:Number, maxY:Number):Boolean
        {
            if (this.maxX < minX)
                return false;
            if (this.minX > maxX)
                return false;
            if (this.maxY < minY)
                return false;
            if (this.minY > maxY)
                return false;

            return true;
        }
		
		public override function clone(object:Clipping = null):Clipping
        {
        	var clipping:NearfieldClipping = (object as NearfieldClipping) || new NearfieldClipping();
        	
        	super.clone(clipping);
        	
        	return clipping;
        }
    }
}