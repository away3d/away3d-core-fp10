package away3d.lights
{
	import away3d.arcane;
    import away3d.core.base.*;
    import away3d.materials.*;
    import away3d.primitives.*;
    
	import flash.display.*;
	
	use namespace arcane;
	
    /**
    * Lightsource that colors all shaded materials evenly from any angle
    */
    public class AmbientLight3D extends AbstractLight
    {        
        private var _ambient:Number;
        
        /**
         * @private
         * Updates the bitmapData object used as the lightmap for ambient light shading.
         * 
         * @param	ambient		The coefficient for ambient light intensity.
         */
		protected override function updateAmbientBitmap():void
        {
        	_ambientBitmap = new BitmapData(256, 256, false, int(_ambient*_red*0xFF << 16) | int(_ambient*_green*0xFF << 8) | int(_ambient*_blue*0xFF));
        	_ambientBitmap.lock();
        	
			_ambientDirty = false;
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
		 * Creates a new <code>AmbientLight3D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function AmbientLight3D(init:Object = null)
        {
            super(init);
            
            ambient = ini.getNumber("ambient", 0.5, {min:0, max:1});
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
