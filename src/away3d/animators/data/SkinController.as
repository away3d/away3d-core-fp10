package away3d.animators.data
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	
    public class SkinController
    {
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
        
        public var sceneTransform:MatrixAway3D = new MatrixAway3D();
        public var inverseTransform:MatrixAway3D;
        public var updated:Boolean;
        
        public function update():void
        {
        	if (!joint)
        		return;
        	
        	if (joint.scene.updatedObjects && !joint.scene.updatedObjects[joint]) {
        		updated = false;
        		return;
        	} else {
        		updated = true;
        	}
        	
        	sceneTransform.multiply(joint.sceneTransform, bindMatrix);
        	sceneTransform.multiply(inverseTransform, sceneTransform);
        }
        
    }
}
