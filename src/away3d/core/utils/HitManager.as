package away3d.core.utils 
{
	import away3d.core.project.PrimitiveType;
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.render.*;
	import away3d.core.session.*;
	import away3d.core.vos.*;
	import away3d.events.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	use namespace arcane;
	
	/**
	 * @author robbateman
	 */
	public class HitManager 
	{
        private var _screenX:Number;
        private var _screenY:Number;
        private var _screenZ:Number = Infinity;
        private var _sceneX:Number;
        private var _sceneY:Number;
        private var _sceneZ:Number;
		private var _view:View3D;
        private var _material:Material;
        private var _elementVO:ElementVO;
        private var _object:Object3D;
		private var _uv:UV;
		
        private var _inv:MatrixAway3D = new MatrixAway3D();
        private var _persp:Number;
		private var _renderer:Renderer;
        private var _hitSourceObject:ViewSourceObject;
        private var _source:Object3D;
        private var _primitiveType:uint;
        private var _primitiveElement:ElementVO;
        private var _container:DisplayObject;
        private var _hitPointX:Number;
        private var _hitPointY:Number;
        
        private var _focus:Number;
        
        
        private function checkSession(session:AbstractSession):void
        {
        	
        	if (session.getContainer(_view).hitTestPoint(_hitPointX, _hitPointY)) {
	        	if (session is BitmapSession) {
	        		_container = (session as BitmapSession).getBitmapContainer(_view);
	        		_hitPointX += _container.x;
	        		_hitPointY += _container.y;
	        	}
	        	
        		_renderer = session.getRenderer(view);
        		
        		var lists:Array = session.getRenderer(_view).list();
        		var priIndex:uint;
	        	for each (priIndex in lists)
	               checkPrimitive(priIndex);
	        	var _sessions:Array = session.sessions;
	        	for each (session in _sessions)
	        		checkSession(session);
	        	
	        	if (session is BitmapSession) {
	        		_container = (session as BitmapSession).getBitmapContainer(_view);
	        		_hitPointX -= _container.x;
	        		_hitPointY -= _container.y;
	        	}
	        }
        	
        }
        
        private function checkPrimitive(priIndex:uint):void
        {
            _primitiveType = _renderer.primitiveType[priIndex];
            
        	if (_primitiveType == PrimitiveType.FOG || _primitiveType == PrimitiveType.DISPLAY_OBJECT)
        		return;
        	
        	_hitSourceObject = _renderer.primitiveSource[priIndex];
        	_source = _hitSourceObject.source;
        	
            if (!_source || !_source._mouseEnabled)
                return;
            
            if (_renderer.primitiveProperties[int(priIndex*9 + 2)] > _screenX)
                return;
            if (_renderer.primitiveProperties[int(priIndex*9 + 3)] < _screenX)
                return;
            if (_renderer.primitiveProperties[int(priIndex*9 + 4)] > _screenY)
                return;
            if (_renderer.primitiveProperties[int(priIndex*9 + 5)] < _screenY)
                return;
            
            _primitiveElement = _renderer.primitiveElements[priIndex];
            
            //if (_primitiveType == PrimitiveType.DISPLAY_OBJECT && !(_primitiveElement as SpriteVO).displayObject.hitTestPoint(_hitPointX, _hitPointY, true))
            //	return;
			
			if (_hitSourceObject.contains(priIndex, _renderer, _screenX, _screenY)) {
                var uvt:Array = _hitSourceObject.getUVT(priIndex, _renderer, _screenX, _screenY);
                if (_screenZ > uvt[2]) {
                    if (_primitiveType == PrimitiveType.FACE) {
                        //return if material pixel is transparent
                        //TODO: sort out eventuality for composite materials
                    	var bitmapMaterial:BitmapMaterial = _renderer.primitiveMaterials[priIndex] as BitmapMaterial;
                        if (bitmapMaterial && !(bitmapMaterial.getPixel32(uvt[0], uvt[1]) >> 24) && !(bitmapMaterial is CompositeMaterial))
                            return;
                        _uv = new UV(uvt[0], uvt[1]);
                    } else {
                        _uv = null;
                    }
                    
                	_screenZ = uvt[2];
                	_material = _renderer.primitiveMaterials[priIndex];
                    
                    //persp = camera.zoom / (1 + screenZ / camera.focus);
					_persp = _view.camera.lens.getPerspective(_screenZ);
                    _inv = _view.camera.invViewMatrix;
					
                    _sceneX = _screenX / _persp * _inv.sxx + _screenY / _persp * _inv.sxy + _screenZ * _inv.sxz + _inv.tx;
                    _sceneY = _screenX / _persp * _inv.syx + _screenY / _persp * _inv.syy + _screenZ * _inv.syz + _inv.ty;
                    _sceneZ = _screenX / _persp * _inv.szx + _screenY / _persp * _inv.szy + _screenZ * _inv.szz + _inv.tz;
                    
                    _object = _source;
                    _elementVO = _primitiveElement;

                }
            }
        
        }
                
        /**
         * 
         */
        public function get screenX():Number
        {
        	return _screenX;
        }
        
        /**
         * 
         */
        public function get screenY():Number
        {
        	return _screenY;
        }
        
        /**
         * 
         */
        public function get screenZ():Number
        {
        	return _screenZ;
        }
        
        /**
         * 
         */
        public function get sceneX():Number
        {
        	return _sceneX;
        }
        
        /**
         * 
         */
        public function get sceneY():Number
        {
        	return _sceneY;
        }
        
        /**
         * 
         */
        public function get sceneZ():Number
        {
        	return _sceneZ;
        }
        
        /**
         * 
         */
        public function get view():View3D
        {
        	return _view;
        }
        
        /**
         * 
         */
        public function get material():Material
        {
        	return _material;
        }
        
        /**
         * 
         */
        public function get elementVO():ElementVO
        {
        	return _elementVO;
        }
        
        /**
         * 
         */
        public function get object():Object3D
        {
        	return _object;
        }
		
        /**
         * 
         */
		public function get uv():UV
        {
        	return _uv;
        }
        
        public function HitManager(view:View3D)
        {
        	_view = view;
        }
        
	    /** 
	     * Finds the object that is rendered under a certain view coordinate. Used for mouse click events.
	     */
        public function findHit(session:AbstractSession, x:Number, y:Number):void
        {
        	_focus = _view.camera.focus;
        	
            _screenX = x;
            _screenY = y;
            _screenZ = Infinity;
            _material = null;
            _object = null;
            
        	if (!session || !_view._mouseIsOverView)
        		return;
        	
            var screenPoint:Point = new Point(x, y);
        	var stagePoint:Point = _view.localToGlobal(screenPoint);
            _hitPointX = stagePoint.x;
            _hitPointY = stagePoint.y;
            
        	if (_view.session is BitmapSession) {
        		_container = _view.session.getContainer(_view);
        		_hitPointX += _container.x;
        		_hitPointY += _container.y;
        	}
        	
            checkSession(session);
        }
        
        /**
         * Returns a 3d mouse event object populated with the properties from the hit point.
         */
        public function getMouseEvent(type:String):MouseEvent3D
        {
            var event:MouseEvent3D = new MouseEvent3D(type);
            event.screenX = _screenX;
            event.screenY = _screenY;
            event.screenZ = _screenZ;
            event.sceneX = _sceneX;
            event.sceneY = _sceneY;
            event.sceneZ = _sceneZ;
            event.view = _view;
            event.material = _material;
            event.elementVO = _elementVO;
            event.object = _object;
            event.uv = _uv;

            return event;
        }
	}
}
