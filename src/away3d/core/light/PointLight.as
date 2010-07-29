package away3d.core.light
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.math.*;
	
	import flash.utils.*;
	
	use namespace arcane;
	
    /**
    * Point light primitive
    */
    public class PointLight extends LightPrimitive
    {
    	public var position:Number3D = new Number3D();
        /**
        * Positions dictionary for the view positions used by shading materials.
        */
        public var viewPositions:Dictionary;
        
    	/**
    	 * Updates the position of the point light.
    	 */
        public function setPosition(scenePosition:Number3D):void
        {
        	//update position vector
        	position.clone(scenePosition);
        	
        	clearViewPositions();
        }
        
        /**
        * Clears the position dictionaries used in the shading materials.
        */
        public function clearViewPositions():void
        {
        	viewPositions = new Dictionary(true);
        }
        
        /**
        * Updates the view position.
        */
        public function setViewPosition(view:View3D):void
        {
        	if (!viewPositions[view])
        		viewPositions[view] = new Number3D();
        	
        	(viewPositions[view] as Number3D).transform(position, view.camera.viewMatrix);
        }
    }
}

