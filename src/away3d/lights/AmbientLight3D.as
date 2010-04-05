package away3d.lights
{
	import away3d.arcane;
	import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.light.*;
    import away3d.materials.*;
    import away3d.primitives.*;
	
	use namespace arcane;
	
    /**
    * Lightsource that colors all shaded materials evenly from any angle
    */
    public class AmbientLight3D extends AbstractLight
    {
        private var _ambient:Number;
    	private var _ambientDirty:Boolean;
		private var _ls:AmbientLight = new AmbientLight();
    	private var _debugPrimitive:Sphere;
        private var _debugMaterial:ColorMaterial;
        
		/** @private */
		protected override function updateParent(val:ObjectContainer3D):void
		{
            _parent = val;
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
			_ambient = val;
            _ambientDirty = true;
		}
        
		public function get debugPrimitive():Object3D
		{
			if (!_debugPrimitive) {
				_debugPrimitive = new Sphere();
				//_scene.clearId(_id);
			}
			
			if (!_debugMaterial) {
				_debugMaterial = new ColorMaterial();
				_debugPrimitive.material = _debugMaterial;
			}
			
            _debugMaterial.color = color;
            
			return _debugPrimitive;
		}
		
		/**
		 * Creates a new <code>AmbientLight3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function AmbientLight3D(init:Object = null)
        {
            super(init);
            
            color = ini.getColor("color", 0xFFFFFF);
            ambient = ini.getNumber("ambient", 0.5, {min:0, max:1});
            debug = ini.getBoolean("debug", false);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function light(consumer:ILightConsumer):void
        {
           //update color
			if (_colorDirty) {
				_ls.red = _red;
				_ls.green = _green;
				_ls.blue = _blue;
	            _colorDirty = false;
			}
        	
        	//update ambient
            if (_ambientDirty) {
        		_ambientDirty = false;
	        	_ls.updateAmbientBitmap(_ambient);
        	}
        	
            consumer.ambientLight(_ls);
        }
		
		/**
		 * Duplicates the light object's properties to another <code>AmbientLight3D</code> object
		 * 
		 * @param	light	[optional]	The new light instance into which all properties are copied
		 * @return						The new light instance with duplicated properties applied
		 */
        public override function clone(light:AbstractLight = null):AbstractLight
        {
            var ambientLight3D:AmbientLight3D = (light as AmbientLight3D) || new AmbientLight3D();
            super.clone(ambientLight3D);
            ambientLight3D.ambient = ambient;
            return ambientLight3D;
        }

    }
}
