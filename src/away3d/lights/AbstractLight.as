package away3d.lights
{
	import flash.geom.ColorTransform;
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	
	import flash.display.*;
	
	use namespace arcane;
	
    /**
    * Lightsource that colors all shaded materials evenly from any angle
    */
    public class AbstractLight
    {
		/** @private */
        arcane var _red:Number;
        /** @private */
        arcane var _green:Number;
        /** @private */
        arcane var _blue:Number;
        
        private var _oldscene:Scene3D;
		/** @private */
		private function onSceneChange(event:Object3DEvent = null):void
        {
        	_oldscene = _scene;
        	
        	if (_scene)
        		_scene.internalRemoveLight(this);
        	
            _scene = _parent.scene;
            
        	if (_scene)
        		_scene.internalAddLight(this);
			
        	onSceneTransformChange();
        }
        /**
         * Instance of the Init object used to hold and parse default property values
         * specified by the initialiser object in the 3d object constructor.
         */
		protected var ini : Init;
		/** @private */
        protected var _color:uint;
        /** @private */
		protected var _parent:ObjectContainer3D;
		/** @private */
		protected var _scene:Scene3D;
		/** @private */
        protected var _debug:Boolean;
        /** @private */
        protected var _ambientColorTransform:ColorTransform;
        /** @private */
        protected var _diffuseColorTransform:ColorTransform;
        /** @private */
        protected var _ambientBitmap:BitmapData;
		/** @private */
        protected var _diffuseBitmap:BitmapData;
        /** @private */
        protected var _ambientDiffuseBitmap:BitmapData;
		/** @private */
    	protected var _specularBitmap:BitmapData;
    	/** @private */
    	protected var _ambientDirty:Boolean;
    	/** @private */
    	protected var _diffuseDirty:Boolean;
    	/** @private */
    	protected var _ambientDiffuseDirty:Boolean;
    	/** @private */
    	protected var _specularDirty:Boolean;
		/** @private */
		protected function updateAmbient():void
		{
			throw new Error("Not implemented");
		}
		/** @private */
		protected function updateDiffuse():void
		{
			throw new Error("Not implemented");
		}
		/** @private */
		protected function updateAmbientDiffuse():void
		{
			throw new Error("Not implemented");
		}
		/** @private */
		protected function updateSpecular():void
		{
			throw new Error("Not implemented");
		}
        /** @private */
		protected function addDebugPrimitive(parent:ObjectContainer3D):void
		{
		}
		/** @private */
		protected function removeDebugPrimitive(parent:ObjectContainer3D):void
		{
		}
		/** @private */
		protected function updateDebugPrimitive():void
		{
		}
		
        /** @private */
		protected function onSceneTransformChange(event:Object3DEvent = null):void
        {
        }
                
        /**
         * Color transform used in cached shading materials for combined ambient and diffuse color intensities.
         */
        public function get ambientColorTransform():ColorTransform
        {
			if (_ambientDirty)
				updateAmbient();
			
        	return _ambientColorTransform;
        }
        
        /**
         * Color transform used in cached shading materials for ambient intensities.
         */
        public function get diffuseColorTransform():ColorTransform
        {
			if (_diffuseDirty)
				updateDiffuse();
			
        	return _diffuseColorTransform;
        }
         
		/**
		 * Lightmap for ambient intensity.
		 */
        public function get ambientBitmap():BitmapData
        {
			if (_ambientDirty)
				updateAmbient();
			
        	return _ambientBitmap;
        }
		
		/**
		 * Lightmap for diffuse intensity.
		 */
        public function get diffuseBitmap():BitmapData
        {
			if (_diffuseDirty)
				updateDiffuse();
			
        	return _diffuseBitmap;
        }
		
		/**
		 * Combined lightmap for ambient and diffuse intensities.
		 */
        public function get ambientDiffuseBitmap():BitmapData
        {
			if (_ambientDiffuseDirty)
				updateAmbientDiffuse();
			
        	return _ambientDiffuseBitmap;
        }
		
		/**
		 * Lightmap for specular intensity.
		 */
    	public function get specularBitmap():BitmapData
        {
			if (_specularDirty)
				updateSpecular();
			
        	return _specularBitmap;
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
            
            _ambientDirty = true;
        	_diffuseDirty = true;
        	_ambientDiffuseDirty = true;
        	_specularDirty = true;
        	
        	if (_debug)
        		updateDebugPrimitive();
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
        	if (_debug == val)
        		return;
        	
        	_debug = val;
        	
        	if (_parent) {
        		if (_debug)
        			addDebugPrimitive(_parent);
        		else
        			removeDebugPrimitive(_parent);
        	}
        	
        	if (_debug)
        		updateDebugPrimitive();
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
			
			_oldscene = _scene;
			
			if (_parent != null) {
                _parent.removeOnSceneChange(onSceneChange);
                _parent.removeOnSceneTransformChange(onSceneTransformChange);
                
                if (_debug)
                	removeDebugPrimitive(_parent);
            }
			
            _parent = val;
			_scene = _parent ? _parent.scene : null;
			
            if (_parent != null) {
                _parent.addOnSceneChange(onSceneChange);
                _parent.addOnSceneTransformChange(onSceneTransformChange);
                
                if (_debug)
					addDebugPrimitive(_parent);
				
                onSceneTransformChange();
            }
			
			
			if (_oldscene != _scene) {
            	if (_oldscene)
            		_oldscene.internalRemoveLight(this);
            	if (_scene)
            		_scene.internalAddLight(this);
			}
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
