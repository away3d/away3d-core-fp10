package away3d.core.light
{
	import away3d.core.draw.ScreenVertex;
	import away3d.lights.PointLight3D;
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
        public var screenPositions:Dictionary;
        
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
        	screenPositions = new Dictionary(true);
        }
        
        /**
        * Updates the view position.
        */
        public function setScreenPosition(view:View3D):void
        {
        	var screenPosition:ScreenVertex = view.camera.screen(light.parent, (light as PointLight3D)._vertex);
        	
        	var persp:Number = view.camera.zoom/(1 + screenPosition.z/view.camera.focus);
        	screenPosition.x /= persp;
        	screenPosition.y /= persp;
        	
        	screenPositions[view] = screenPosition;
        }
    }
}

