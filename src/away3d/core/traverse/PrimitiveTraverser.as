package away3d.core.traverse
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.geom.*;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	import away3d.materials.*;
    
    import flash.geom.*;
    
	use namespace arcane;
	
    /**
    * Traverser that gathers drawing primitives to render the scene.
    */
    public class PrimitiveTraverser extends Traverser
    {
    	private var _view:View3D;
    	private var _clipping:Clipping;
    	private var _viewTransform:Matrix3D;
    	private var _cameraVarsStore:CameraVarsStore;
    	private var _nodeClassification:int;
    	private var _consumer:Renderer;
    	private var _mouseEnabled:Boolean;
    	private var _mouseEnableds:Array = new Array();
		
		/**
		 * Defines the view being used.
		 */
		public function get view():View3D
		{
			return _view;
		}
		public function set view(val:View3D):void
		{
			_view = val;
			_mouseEnabled = true;
			_mouseEnableds.length = 0;
			_cameraVarsStore = _view.cameraVarsStore;
		}
		    	
		/**
		 * Creates a new <code>PrimitiveTraverser</code> object.
		 */
        public function PrimitiveTraverser()
        {
        }
        
		/**
		 * @inheritDoc
		 */
		public override function match(node:Object3D):Boolean
        {
        	_clipping = _view.clipping;
        	
        	if (node._preCulled)
        		return true;
        	
        	if (!node.visible || (_clipping.objectCulling && !_cameraVarsStore.nodeClassificationDictionary[node]))
                return false;
            
            if (node is ILODObject)
                return (node as ILODObject).matchLOD(_view.camera);
            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function enter(node:Object3D):void
        {
        	node;//TODO : FDT Warning
        	_mouseEnableds.push(_mouseEnabled);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function apply(node:Object3D):void
        {
        	if (!(node is Mesh))
        		return;
        	
        	if (node.session.updated) {
	        	_viewTransform = _cameraVarsStore.viewTransformDictionary[node];
	        	_consumer = node.session.getRenderer(_view);
	        	
	        	
				_view._primitiveProjector.project(node, _viewTransform, _consumer);
	            
	            if (node.debugbb && node.debugBoundingBox.visible) {
	            	node.debugBoundingBox._session = node.session;
	            	if (_clipping.objectCulling) {
	            		_cameraVarsStore.frustumDictionary[node.debugBoundingBox] = _cameraVarsStore.frustumDictionary[node];
	            		_nodeClassification = _cameraVarsStore.nodeClassificationDictionary[node];
	            		if (_nodeClassification == Frustum.INTERSECT)
	            			(node.debugBoundingBox.material as WireframeMaterial).wireColor = 0xFF0000;
	            		else
	            			(node.debugBoundingBox.material as WireframeMaterial).wireColor = 0x333333;
	            	}
	            	_view._primitiveProjector.project(node.debugBoundingBox, _viewTransform, _consumer);
	            }
	            
	            if (node.debugbs && node.debugBoundingSphere.visible) {
	            	node.debugBoundingSphere._session = node.session;
	            	if (_clipping.objectCulling) {
	            		_cameraVarsStore.frustumDictionary[node.debugBoundingSphere] = _cameraVarsStore.frustumDictionary[node];
	            		_nodeClassification = _cameraVarsStore.nodeClassificationDictionary[node];
	            		if (_nodeClassification == Frustum.INTERSECT)
	            			(node.debugBoundingSphere.material as WireframeMaterial).wireColor = 0xFF0000;
	            		else
	            			(node.debugBoundingSphere.material as WireframeMaterial).wireColor = 0x00FFFF;
	            	}
	            	_view._primitiveProjector.project(node.debugBoundingSphere, _viewTransform, _consumer);
	            }
	        }
	        
            _mouseEnabled = node._mouseEnabled = (_mouseEnabled && node.mouseEnabled);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function leave(node:Object3D):void
        {
        	delete _view._updatedObjects[node];
        	node;//TODO : FDT Warning
        	_mouseEnabled = _mouseEnableds.pop();
        }

    }
}
