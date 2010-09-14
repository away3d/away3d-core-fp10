package away3d.cameras.lenses
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.geom.*;
	
	import flash.geom.*;
	
	use namespace arcane;
	
	public class PerspectiveLens extends AbstractLens
	{
		/** @private */
		arcane override function setView(val:View3D):void
		{
			super.setView(val);
			
			if (_clipping.minZ == -Infinity)
        		_near = _camera.focus/2;
        	else
        		_near = _clipping.minZ;
        	
			_projectionMatrix.rawData = Vector.<Number>([_camera.zoom*_camera.focus, 0, 0, 0, 0, _camera.zoom*_camera.focus, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0]);
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
			//calculated from the arctan addition formula arctan(x) + arctan(y) = arctan(x + y / 1 - x*y)
			return Math.atan2(_clipHeight, _camera.focus*_camera.zoom + _clipTop*_clipBottom/(_camera.focus*_camera.zoom))*toDEGREES;
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
			return _camera.focus*_camera.zoom/screenZ;
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
        	_screenMatrix.rawData = _projectionMatrix.rawData;
			_screenMatrix.prepend(viewTransform);
        	Utils3D.projectVectors(_screenMatrix, verts, screenVerts, uvts);
        }
	}
}