package away3d.cameras.lenses
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.geom.*;
	
	import flash.geom.*;
	
	use namespace arcane;
	
	public class SphericalLens extends AbstractLens
	{
		/** @private */
		arcane override function setView(val:View3D):void
		{
			super.setView(val);
			
			if (_clipping.minZ == -Infinity)
        		_near = _camera.focus/2;
        	else
        		_near = _clipping.minZ;
		}
		/** @private */
		arcane override function getFrustum(node:Object3D, viewTransform:Matrix3D):Frustum
		{
			_frustum = _cameraVarsStore.createFrustum(node);
			_focusOverZoom = _camera.focus/_camera.zoom;
			_zoom2 = _camera.zoom*_camera.zoom;
			
			_plane = _frustum.planes[Frustum.NEAR];
			_plane.a = 0;
			_plane.b = 0;
			_plane.c = 1;
			_plane.d = -_near;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.FAR];
			_plane.a = 0;
			_plane.b = 0;
			_plane.c = -1;
			_plane.d = _far;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.LEFT];
			_plane.a = _clipHeight*_focusOverZoom;
			_plane.b = 0;
			_plane.c = -_clipHeight*_clipLeft/_zoom2;
			_plane.d = 0;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.RIGHT];
			_plane.a = -_clipHeight*_focusOverZoom;
			_plane.b = 0;
			_plane.c = _clipHeight*_clipRight/_zoom2;
			_plane.d = 0;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.TOP];
			_plane.a = 0;
			_plane.b = _clipWidth*_focusOverZoom;
			_plane.c = -_clipWidth*_clipTop/_zoom2;
			_plane.d = 0;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.BOTTOM];
			_plane.a = 0;
			_plane.b = -_clipWidth*_focusOverZoom;
			_plane.c = _clipWidth*_clipBottom/_zoom2;
			_plane.d = 0;
			_plane.transform(viewTransform);
			
			return _frustum;
		}
		/** @private */
		arcane override function getFOV():Number
		{
			return Math.atan2(_clipTop - _clipBottom, _camera.focus*_camera.zoom + _clipTop*_clipBottom)*toDEGREES;
		}
		/** @private */
		arcane override function getZoom():Number
		{
			var b:Number = _clipHeight/Math.tan(_camera.fov*toRADIANS);
			return (b + Math.sqrt(Math.pow(b, 2) - 4*_clipTop*_clipBottom/_camera.zoom))/(2*_camera.focus);
		}
        /** @private */
		arcane override function getPerspective(screenZ:Number):Number
		{
			return _camera.focus*_camera.zoom / screenZ;
		}
		/** @private */
		arcane override function getT(screenZ:Number):Number
		{
			return 1/screenZ;
		}
		/** @private */
		arcane override function getScreenZ(t:Number):Number
		{
			return 1/t;
		}
		/** @private */
		arcane override function project(viewTransform:Matrix3D, verts:Vector.<Number>, screenVerts:Vector.<Number>, uvts:Vector.<Number>):void
        {
			_length = uvts.length = verts.length;
			
			var index1:uint = 0;
			var index2:uint = 0;
        	while (index1 < _length) {
        		
	        	_vector.x = verts[index1];
	        	_vector.y = verts[uint(index1 + 1)];
	        	_vector.z = verts[uint(index1 + 2)];
				_vector = viewTransform.transformVector(_vector);
	    		_wx = _vector.x;
	    		_wy = _vector.y;
	    		_wz = _vector.z;
	    		
				_wx2 = _wx*_wx;
				_wy2 = _wy*_wy;
	    		_c = Math.sqrt(_wx2 + _wy2 + _wz*_wz);
				_c2 = (_wx2 + _wy2);
				_sz = (_c != 0 && _wz != -_c)? _c*Math.sqrt(0.5 + 0.5*_wz/_c) : 0;
	    		
	            if (isNaN(_sz))
	                throw new Error("isNaN(sz)");
	            
	            if (_sz < _near && _clipping is RectangleClipping) {
	                screenVerts[index2] = 0;
	                screenVerts[uint(index2+1)] = 0;
	                uvts[uint(index1+2)] = 0;
	                index1 += 3;
	                index2 += 2;
	                continue;
	            }
	            
				_persp = _c2? _camera.zoom*_camera.focus*(_c - _wz)/_c2 : 0;
				
	            screenVerts[index2] = _wx * _persp;
	            screenVerts[uint(index2+1)] = _wy * _persp;
	            uvts[uint(index1+2)] = 1/_sz;
	            index1 += 3;
	            index2 += 2;
	        }
        }
        
		private var _length:int;
		private var _vector:Vector3D = new Vector3D();
		private var _wx:Number;
		private var _wy:Number;
		private var _wz:Number;
		private var _wx2:Number;
		private var _wy2:Number;
		private var _c:Number;
		private var _c2:Number;
	}
}