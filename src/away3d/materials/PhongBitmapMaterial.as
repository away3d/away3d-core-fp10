package away3d.materials
{
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	
	/**
	 * Bitmap material with phong shading.
	 */
	public class PhongBitmapMaterial extends CompositeMaterial
	{
		private var _shininess:Number;
		private var _specular:uint;
		private var _textureMaterial:TransformBitmapMaterial;
		private var _phongShader:CompositeMaterial;
		private var _ambientShader:AmbientShader;
		private var _diffusePhongShader:DiffusePhongShader;
		private var _specularPhongShader:SpecularPhongShader;
		
		/**
		 * The exponential dropoff value used for specular highlights.
		 */
		public function get shininess():Number
		{
			return _shininess;
		}
		
		public function set shininess(val:Number):void
		{
			_shininess = val;
			_specularPhongShader.shininess = val;
		}
		
		/**
		 * Color value for specular light.
		 */
		public function get specular():uint
		{
			return _specular;
		}
		
		public function set specular(val:uint):void
		{
			if (_specular == val)
				return;
			
			_specular = val;
			_specularPhongShader.specular = val;
			
			if (_specular && materials.length < 3)
        		addMaterial(_specularPhongShader);
   			else if (!_specular && materials.length > 2)
            	removeMaterial(_specularPhongShader);
		}
        
        /**
        * Returns the bitmap material being used as the material texture.
        */
		public function get textureMaterial():BitmapMaterial
		{
			return _textureMaterial;
		}
		
		/**
		 * Creates a new <code>PhongBitmapMaterial</code> object.
		 * 
		 * @param	bitmap				The bitmapData object to be used as the material's texture.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function PhongBitmapMaterial(bitmap:BitmapData, init:Object = null)
		{
			if (init && init["materials"])
				delete init["materials"];
			
			super(init);
			
			_shininess = ini.getNumber("shininess", 20);
			_specular = ini.getColor("specular", 0xFFFFFF);
			
			//create new materials
			_textureMaterial = new TransformBitmapMaterial(bitmap, ini);
			_phongShader = new CompositeMaterial({blendMode:BlendMode.MULTIPLY});
			_phongShader.addMaterial(_ambientShader = new AmbientShader({blendMode:BlendMode.ADD}));
			_phongShader.addMaterial(_diffusePhongShader = new DiffusePhongShader({blendMode:BlendMode.ADD}));
			_specularPhongShader = new SpecularPhongShader({shininess:_shininess, specular:_specular, blendMode:BlendMode.ADD});
			
			//add to materials array
			addMaterial(_textureMaterial);
			addMaterial(_phongShader);
			
			if (_specular)
				addMaterial(_specularPhongShader);
		}
	}
}