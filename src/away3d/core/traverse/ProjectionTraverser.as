package away3d.core.traverse
{
	import away3d.arcane;
	import away3d.cameras.*;
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.geom.*;
	import away3d.graphs.bsp.BSPTree;
	import away3d.core.utils.*;
	
	import flash.geom.*;
	
	use namespace arcane;
	
    /**
    * Traverser that resolves the transform tree in a scene, ready for rendering.
    */
    public class ProjectionTraverser extends Traverser
    {
        private var _view:View3D;
        private var _frustum:Frustum;
        private var _cameraVarsStore:CameraVarsStore;
        private var _camera:Camera3D;
        private var _lens:AbstractLens;
        private var _clipping:Clipping;
        private var _cameraViewMatrix:Matrix3D;
        private var _viewTransform:Matrix3D;
        private var _nodeClassification:int;
        private var _mesh:Mesh;
		
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
			_cameraVarsStore = val.cameraVarsStore;
			_clipping = val.clipping;
			_camera = val.camera;
			_lens = _camera.lens;
            _cameraViewMatrix = _camera.viewMatrix;
			if (val.statsOpen)
				val.statsPanel.clearObjects();
		}
		    	
		/**
		 * Creates a new <code>ProjectionTraverser</code> object.
		 */
        public function ProjectionTraverser()
        {
        }
        
		/**
		 * @inheritDoc
		 */
        public override function match(node:Object3D):Boolean
        {
        	//check if node is visible
            if (!node.visible)
                return false;
            
            //compute viewTransform matrix
            _viewTransform = _cameraVarsStore.createViewTransform(node);
            _viewTransform.rawData = _cameraViewMatrix.rawData;
            _viewTransform.prepend(node.sceneTransform);
            
            if (node is BSPTree) {
            	BSPTree(node).update(_camera, _lens.getFrustum(node, _viewTransform), _cameraVarsStore);
            	_cameraVarsStore.nodeClassificationDictionary[node] = Frustum.INTERSECT;
			}
            // only check culling if not pre-culled by a scene graph
            else if (_clipping.objectCulling) {
            	if (node._preCulled) {
            		_cameraVarsStore.nodeClassificationDictionary[node] = node._preCullClassification;
            		return true;
            	}
            	else {
		        	_frustum = _lens.getFrustum(node, _viewTransform);
		        	
		            if ((node is Scene3D || _cameraVarsStore.nodeClassificationDictionary[node.parent] == Frustum.INTERSECT)) {
		            	if (node.pivotZero)
		            		_nodeClassification = _cameraVarsStore.nodeClassificationDictionary[node] = _frustum.classifyRadius(node.boundingRadius);
		            	else
		            		_nodeClassification = _cameraVarsStore.nodeClassificationDictionary[node] = _frustum.classifySphere(node.pivotPoint, node.boundingRadius);
		            } else {
		            	_nodeClassification = _cameraVarsStore.nodeClassificationDictionary[node] = _cameraVarsStore.nodeClassificationDictionary[node.parent];
		            }
		            if (_nodeClassification == Frustum.OUT) {
		            	return false;
		            }
            	}
            	
            	//check which LODObject is visible
	            if (node is ILODObject)
	                return (node as ILODObject).matchLOD(_camera);
            }
            
            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function enter(node:Object3D):void
        {
        	if (_view.statsOpen && node is Mesh)
        		_view.statsPanel.addObject(node as Mesh);
        }
        
        public override function apply(node:Object3D):void
        { 
        	//add to scene meshes dictionary
            if ((_mesh = node as Mesh))
            	_mesh.updateMesh(_view);
        }
        
        public override function leave(node:Object3D):void
        {
        }
    }
}
