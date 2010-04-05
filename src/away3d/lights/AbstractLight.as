package away3d.lights
{
	import away3d.arcane;
	import away3d.containers.*;
    import away3d.core.light.*;
	import away3d.core.utils.*;
	
	use namespace arcane;
	
    /**
    * Lightsource that colors all shaded materials evenly from any angle
    */
    public class AbstractLight implements ILightProvider
    {
        private var _debug:Boolean;
        
        /**
         * Instance of the Init object used to hold and parse default property values
         * specified by the initialiser object in the 3d object constructor.
         */
		protected var ini : Init;
		/** @private */
        protected var _color:uint;
        /** @private */
		protected var _colorDirty:Boolean;
		/** @private */
        protected var _red:Number;
        /** @private */
        protected var _green:Number;
        /** @private */
        protected var _blue:Number;
        /** @private */
		protected var _parent:ObjectContainer3D;
		/** @private */
		protected function updateParent(val:ObjectContainer3D):void
		{
			throw new Error("Not implemented");
		}

		/**
		 * Defines the color of the light object.
		 */
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(val:uint):void
		{
			_color = val;
			_red = ((_color & 0xFF0000) >> 16)/255;
            _green = ((_color & 0xFF00) >> 8)/255;
            _blue  = (_color & 0xFF)/255;
            _colorDirty = true;
		}
        
        /**
        * Toggles debug mode: light object is visualised in the scene.
        */
        public function get debug():Boolean
        {
        	return _debug;
        }
        
        public function set debug(val:Boolean):void
        {
        	_debug = val;
        }
				
    	/**
    	 * Defines the parent of the light.
    	 */
        public function get parent():ObjectContainer3D
        {
            return _parent;
        }
		
        public function set parent(val:ObjectContainer3D):void
        {
            if (val == _parent)
                return;
			
			updateParent(val);
        }
        
		/**
		 * Creates a new <code>AmbientLight3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function AbstractLight(init:Object = null)
        {
            ini = Init.parse(init);
            
            color = ini.getColor("color", 0xFFFFFF);
            debug = ini.getBoolean("debug", false);
        }
        
		/**
		 * @inheritDoc
		 */
        public function light(consumer:ILightConsumer):void
        {
           throw new Error("Not implemented");
        }
		
		/**
		 * Duplicates the light object's properties to another <code>AbstractLight</code> object
		 * 
		 * @param	light	[optional]	The new light instance into which all properties are copied
		 * @return						The new light instance with duplicated properties applied
		 */
        public function clone(light:AbstractLight = null):AbstractLight
        {
            var abstractLight:AbstractLight = (light as AbstractLight) || new AbstractLight();
            super.clone(abstractLight);
            abstractLight.color = color;
            abstractLight.debug = debug;
            return abstractLight;
        }
    }
}
