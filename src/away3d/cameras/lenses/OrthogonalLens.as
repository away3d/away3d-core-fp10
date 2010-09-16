package away3d.cameras.lenses
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.geom.*;
	
	import flash.geom.*;
	
	use namespace arcane;
	
	public class OrthogonalLens extends AbstractLens
	{
		/** @private */
		arcane override function setView(val:View3D):void
		{
			super.setView(val);
			
			if (_clipping.minZ == -Infinity)
        		_near = _camera.focus/2;
        	else
        		_near = _clipping.minZ;
        	
			_projectionMatrix.rawData = Vector.<Number>([_camera.zoom/_camera.focus, 0, 0, 0, 0, _camera.zoom/_camera.focus, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
		}
		/** @private */
		arcane override function getFrustum(node:Object3D, viewTransform:Matrix3D):Frustum
		{
			_frustum = _cameraVarsStore.createFrustum(node);
			_focusOverZoom = _camera.focus/_camera.zoom;
			
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
			_plane.a = 1;
			_plane.b = 0;
			_plane.c = 0;
			_plane.d = -_clipLeft*_focusOverZoom;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.RIGHT];
			_plane.a = -1;
			_plane.b = 0;
			_plane.c = 0;
			_plane.d = _clipRight*_focusOverZoom;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.TOP];
			_plane.a = 0;
			_plane.b = 1;
			_plane.c = 0;
			_plane.d = _clipTop*_focusOverZoom;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.BOTTOM];
			_plane.a = 0;
			_plane.b = -1;
			_plane.c = 0;
			_plane.d = -_clipBottom*_focusOverZoom;
			_plane.transform(viewTransform);
			
			return _frustum;
		}
		/** @private */
		arcane override function getFOV():Number
		{
			return 0;
		}
		/** @private */
		arcane override function getZoom():Number
		{
			return _camera.zoom;
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
		
        /**
         * @inheritDoc
         */
		public override function getPerspective(screenZ:Number):Number
		{
			screenZ;
			return _camera.zoom/_camera.focus;
		}
	}
}