package away3d.primitives.data
{
	import away3d.core.utils.Init;
	import away3d.events.*;
	import away3d.materials.*;
	
	import flash.events.EventDispatcher;
    
	 /**
	 * Dispatched when the cube materials object has one of it's materials updated.
	 * 
	 * @eventType away3d.events.MaterialEvent
	 */
	[Event(name="materialchanged",type="away3d.events.MaterialEvent")]
	
	/**
	 * Data structure for individual materials on the sides of a cube.
	 * 
	 * @see away3d.primitives.Cube
	 * @see away3d.primitives.Skybox
	 */
	public class CubeMaterialsData extends EventDispatcher
	{
		private var _materialchanged:MaterialEvent;
		private var _left:Material;
		private var _right:Material;
		private var _bottom:Material;
		private var _top:Material;
		private var _front:Material;
		private var _back:Material;
		 
		private function notifyMaterialChange(material:Material, faceString:String):void
		{
            if (!hasEventListener(MaterialEvent.MATERIAL_CHANGED))
                return;
                
          //if (!_materialchanged)
            _materialchanged = new MaterialEvent(MaterialEvent.MATERIAL_CHANGED, material);
            /*else
            	_materialchanged.material = material; */
            
            _materialchanged.extra = faceString;
            
            dispatchEvent(_materialchanged);
		}
		
        /**
        * Instance of the Init object used to hold and parse default property values
        * specified by the initialiser object in the 3d object constructor.
        */
		protected var ini:Init;
		
    	/**
    	 * Defines the material applied to the left side of the cube.
    	 */
    	public function get left():Material
    	{
    		return _left;
    	}
    	
    	public function set left(val:Material):void
    	{
    		if (_left == val)
    			return;
    		
    		_left = val;
    		
    		notifyMaterialChange(_left, "left");
    	}
    	
    	/**
    	 * Defines the material applied to the right side of the cube.
    	 */
    	public function get right():Material
    	{
    		return _right;
    	}
    	
    	public function set right(val:Material):void
    	{
    		if (_right == val)
    			return;
    		
    		_right = val;
    		
    		notifyMaterialChange(_right, "right");
    	}
		
    	/**
    	 * Defines the material applied to the bottom side of the cube.
    	 */
    	public function get bottom():Material
    	{
    		return _bottom;
    	}
    	
    	public function set bottom(val:Material):void
    	{
    		if (_bottom == val)
    			return;
    		
    		_bottom = val;
    		
    		notifyMaterialChange(_bottom, "bottom");
    	}
		
    	/**
    	 * Defines the material applied to the top side of the cube.
    	 */
    	public function get top():Material
    	{
    		return _top;
    	}
    	
    	public function set top(val:Material):void
    	{
    		if (_top == val)
    			return;
    		
    		_top = val;
    		
    		notifyMaterialChange(_top, "top");
    	}
		
    	/**
    	 * Defines the material applied to the front side of the cube.
    	 */
    	public function get front():Material
    	{
    		return _front;
    	}
    	
    	public function set front(val:Material):void
    	{
    		if (_front == val)
    			return;
    		
    		_front = val;
    		
    		notifyMaterialChange(_front, "front");
    	}
		
    	/**
    	 * Defines the material applied to the back side of the cube.
    	 */
    	public function get back():Material
    	{
    		return _back;
    	}
    	
    	public function set back(val:Material):void
    	{
    		if (_back == val)
    			return;
    		
    		_back = val;
    		
    		notifyMaterialChange(_back, "back");
    	}
    	
		/**
		 * Creates a new <code>CubeMaterialsData</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function CubeMaterialsData(init:Object = null)
        {
        	ini = Init.parse(init);
        	
        	_left = ini.getMaterial("left") as Material;
        	_right = ini.getMaterial("right") as Material;
        	_bottom = ini.getMaterial("bottom") as Material;;
        	_top = ini.getMaterial("top") as Material;
        	_front = ini.getMaterial("front") as Material;
        	_back = ini.getMaterial("back") as Material;
        }
        
		/**
		 * Default method for adding a materialChanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnMaterialChange(listener:Function):void
        {
            addEventListener(MaterialEvent.MATERIAL_CHANGED, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a materialChanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnMaterialChange(listener:Function):void
        {
            removeEventListener(MaterialEvent.MATERIAL_CHANGED, listener, false);
        }
	}
}