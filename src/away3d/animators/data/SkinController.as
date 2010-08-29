package away3d.animators.data
{
	import away3d.core.base.Geometry;
	import away3d.core.base.Vertex;
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.math.*;
	
	use namespace arcane;
	
    public class SkinController
    {
    	private var _sceneTransform:MatrixAway3D = new MatrixAway3D();
    	private var _sceneTransformDirty:Boolean;
    	
        /**
         * Reference to the name of the controlling <code>Bone</code> object.
         */
    	public var name:String;
    	
    	/**
    	 * Reference to the joint of the controlling <code>Bone</code> object.
    	 */
		public var joint:ObjectContainer3D;
		
		/**
		 * Defines the 3d matrix that transforms the position of the <code>Bone</code> to the position of the <code>SkinVertices</code>.
		 */
        public var bindMatrix:MatrixAway3D;
                
        /**
         * Store of all <code>SkinVertex</code> objects being controlled
         */
        public var skinVertices:Array =  new Array();
        
        public function get sceneTransform():MatrixAway3D
		{
			if (_sceneTransformDirty) {
				_sceneTransformDirty = false;
	        	sceneTransform.multiply(joint.sceneTransform, bindMatrix);
	        	sceneTransform.multiply(inverseTransform, sceneTransform);
			}
			
			return _sceneTransform;
		}
		
        public var inverseTransform:MatrixAway3D;
        
        public function update():void
        {
        	if (!joint || _sceneTransformDirty)
        		return;
        	
        	_sceneTransformDirty = true;
        	
        	var child:Bone;
        	for each (child in joint.children)
        		if (child && child.controller)
        			child.controller.update();
        	
			var skinVertex:SkinVertex;
        	for each (skinVertex in skinVertices) {
        		skinVertex.skinnedVertex._positionDirty = true;
        		if (skinVertex.skinnedVertex.geometry)
        			skinVertex.skinnedVertex.geometry.notifyGeometryUpdate();
			}
        }
        
    }
}
