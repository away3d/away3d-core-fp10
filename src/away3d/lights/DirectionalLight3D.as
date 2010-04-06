package away3d.lights
{
	import away3d.arcane;
	import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.light.*;
	import away3d.core.math.*;
	import away3d.events.*;
    import away3d.materials.ColorMaterial;
    import away3d.primitives.Sphere;
	
	use namespace arcane;
	
    /**
    * Lightsource that colors all shaded materials proportional to the dot product of the offset vector with the normal vector.
    * The scalar value of distance does not affect the resulting light intensity, it is calulated as if the
    * source is an infinite distance away with an infinite brightness.
    */
    public class DirectionalLight3D extends AbstractLight
    {
    	private var _direction:Number3D = new Number3D();
        private var _ambient:Number;
        private var _diffuse:Number;
        private var _specular:Number;
        private var _brightness:Number;
    	private var _sceneDirection:Number3D = new Number3D();
    	private var _sceneDirectionDirty:Boolean;
    	
    	private var _ambientDirty:Boolean;
    	private var _diffuseDirty:Boolean;
    	private var _specularDirty:Boolean;
		private var _ls:DirectionalLight = new DirectionalLight();
		private var _debugPrimitive:Sphere;
        private var _debugMaterial:ColorMaterial;
		
		private function onParentChange(event:Object3DEvent):void
        {
			_sceneDirectionDirty = true;
        }
        
    	/** @private */
		protected override function updateParent(val:ObjectContainer3D):void
		{
			if (_parent != null) {
                _parent.removeOnSceneChange(onParentChange);
                _parent.removeOnSceneTransformChange(onParentChange);
            }
			
            _parent = val;
			
            if (_parent != null) {
                _parent.addOnSceneChange(onParentChange);
                _parent.addOnSceneTransformChange(onParentChange);
                
                _sceneDirectionDirty = true;
            }
		}
		        
    	/**
    	 * Defines the direction of the light relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function get direction():Number3D
        {
            return _direction;
        }
		
        public function set direction(value:Number3D):void
        {
            _direction.x = value.x;
            _direction.y = value.y;
            _direction.z = value.z;
            
			_sceneDirectionDirty = true;
        }
        
		/**
		 * Defines a coefficient for the ambient light intensity.
		 */
		public function get ambient():Number
		{
			return _ambient;
		}
		public function set ambient(val:Number):void
		{
			if (val < 0)
				val  = 0;
			_ambient = val;
            _ambientDirty = true;
		}
		
		/**
		 * Defines a coefficient for the diffuse light intensity.
		 */
		public function get diffuse():Number
		{
			return _diffuse;
		}
		
		public function set diffuse(val:Number):void
		{
			if (val < 0)
				val  = 0;
			_diffuse = val;
            _diffuseDirty = true;
		}
		
		/**
		 * Defines a coefficient for the specular light intensity.
		 */
		public function get specular():Number
		{
			return _specular;
		}
		
		public function set specular(val:Number):void
		{
			if (val < 0)
				val  = 0;
			_specular = val;
            _specularDirty = true;
		}
		
		/**
		 * Defines a coefficient for the overall light intensity.
		 */
		public function get brightness():Number
		{
			return _brightness;
		}
		
		public function set brightness(val:Number):void
		{
			_brightness = val;
            
            _ambientDirty = true;
            _diffuseDirty = true;
            _specularDirty = true;
		}
        
		public function get debugPrimitive():Object3D
		{
			if (!_debugPrimitive) {
				_debugPrimitive = new Sphere({radius:10});
				//_scene.clearId(_id);
			}
			
			if (!_debugMaterial) {
				_debugMaterial = new ColorMaterial();
				_debugPrimitive.material = _debugMaterial;
			}
			
            _debugMaterial.color = color;
            
			return _debugPrimitive;
		}
		
		
		public function get sceneDirection():Number3D
		{
			if (_sceneDirectionDirty) {
				_sceneDirectionDirty = false;
				
				_sceneDirection.rotate(_direction, _parent.sceneTransform);
				
				_ls.setDirection(_sceneDirection);
			}
			
			return _sceneDirection;
		}
		
		/**
		 * Creates a new <code>DirectionalLight3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function DirectionalLight3D(init:Object = null)
        {
            super(init);
            direction = ini.getNumber3D("direction") || new Number3D();
            ambient = ini.getNumber("ambient", 0.5, {min:0, max:1});
            diffuse = ini.getNumber("diffuse", 0.5, {min:0, max:10});
            specular = ini.getNumber("specular", 1, {min:0, max:1});
            brightness = ini.getNumber("brightness", 1);
            debug = ini.getBoolean("debug", false);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function light(consumer:ILightConsumer):void
        {
        	//update direction
        	if (_sceneDirectionDirty) {
        		_sceneDirectionDirty = false;
				
				_sceneDirection.rotate(_direction, _parent.sceneTransform);
				
				_ls.setDirection(_sceneDirection);
        	}
        	
            //update color
			if (_colorDirty) {
				_ls.red = _red;
				_ls.green = _green;
				_ls.blue = _blue;
				
				_ambientDirty = true;
            	_diffuseDirty = true;
            	_specularDirty = true;
			}
        	
        	//update coefficients
        	_ls.ambient = _ambient;
        	_ls.diffuse = _diffuse*_brightness;
        	_ls.specular = _specular*_brightness;
        	
        	//update ambient diffuse
            if (_ambientDirty || _diffuseDirty)
	        	_ls.updateAmbientDiffuseBitmap();
        	
        	//update ambient
            if (_ambientDirty) {
        		_ambientDirty = false;
	        	_ls.updateAmbientBitmap();
        	}
            
        	//update diffuse
        	if (_diffuseDirty) {
        		_diffuseDirty = false;
	        	_ls.updateDiffuseBitmap();
        	}
        	
        	//update specular
        	if (_specularDirty) {
        		_specularDirty = false;
        		_ls.updateSpecularBitmap();
        	}
        	
            consumer.directionalLight(_ls);
            
            _colorDirty = false;
        }
		
		/**
		 * Duplicates the light object's properties to another <code>DirectionalLight3D</code> object
		 * 
		 * @param	light	[optional]	The new light instance into which all properties are copied
		 * @return						The new light instance with duplicated properties applied
		 */
        public override function clone(light:AbstractLight = null):AbstractLight
        {
            var directionalLight3D:DirectionalLight3D = (light as DirectionalLight3D) || new DirectionalLight3D();
            super.clone(directionalLight3D);
            directionalLight3D.brightness = brightness;
            directionalLight3D.ambient = ambient;
            directionalLight3D.diffuse = diffuse;
            directionalLight3D.specular = specular;
            return directionalLight3D;
        }

    }
}
