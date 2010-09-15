package away3d.animators.data
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	
	import flash.geom.*;
	
	use namespace arcane;
	
    public class SkinController
    {
    	private var _sceneTransform:Matrix3D = new Matrix3D();
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
        public var bindMatrix:Matrix3D;
                
        /**
         * Store of all <code>SkinVertex</code> objects being controlled
         */
        public var skinVertices:Vector.<SkinVertex> =  new Vector.<SkinVertex>();
        
        public function get sceneTransform():Matrix3D
		{
			if (_sceneTransformDirty) {
				_sceneTransformDirty = false;
				sceneTransform.rawData = joint.sceneTransform.rawData;
	        	sceneTransform.prepend(bindMatrix);
	        	sceneTransform.append(inverseTransform);
			}
			
			return _sceneTransform;
		}
		
        public var inverseTransform:Matrix3D;
        
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
