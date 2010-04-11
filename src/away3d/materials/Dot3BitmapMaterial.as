package away3d.materials
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	
	use namespace arcane;
	
	/**
	 * Bitmap material with DOT3 shading.
	 */
	public class Dot3BitmapMaterial extends CompositeMaterial
	{
		/** @private */
        arcane override function updateMaterial(source:Object3D, view:View3D):void
        {
        	if (_normalBitmapDirty)
        		updateNormalBitmap();
        	
        	super.updateMaterial(source, view);
        }
        
		private var _shininess:Number;
		private var _specular:uint;
		private var _normalBitmap:BitmapData;
		private var _renderNormalBitmap:BitmapData;
		private var _textureMaterial:BitmapMaterial;
		private var _phongShader:CompositeMaterial;
		private var _ambientShader:AmbientShader;
		private var _diffuseDot3Shader:DiffuseDot3Shader;
		private var _specularDot3Shader:SpecularDot3Shader;
		private var _normalBitmapDirty:Boolean;
		
		private function updateNormalBitmap():void
		{
			_normalBitmapDirty = false;
			
            var w:int = _normalBitmap.width;
			var h:int = _normalBitmap.height;
			
			var i:int = h;
			var j:int;
			var pixelValue:int;
			var rValue:Number;
			var gValue:Number;
			var bValue:Number;
			var mod:Number;
			
			_renderNormalBitmap = new BitmapData(_normalBitmap.width, _normalBitmap.height, true, 0);
			//normalise map
			while (i--) {
				j = w;
				while (j--) {
					//get values
					pixelValue = _normalBitmap.getPixel32(j, i);
					rValue = ((pixelValue & 0x00FF0000) >> 16) - 127;
					gValue = ((pixelValue & 0x0000FF00) >> 8) - 127;
					bValue = ((pixelValue & 0x000000FF)) - 127;
					
					//calculate modulus
					mod = Math.sqrt(rValue*rValue + gValue*gValue + bValue*bValue)*2;
					
					//set normalised values
					_renderNormalBitmap.setPixel32(j, i, (0xFF << 24) + (int(0xFF*(rValue/mod + 0.5)) << 16) + (int(0xFF*(gValue/mod + 0.5)) << 8) + int(0xFF*(bValue/mod + 0.5)));
				}
			}
			
			if (_diffuseDot3Shader)
				_diffuseDot3Shader.bitmap = _renderNormalBitmap;
			
			if (_specularDot3Shader)
				_specularDot3Shader.bitmap = _renderNormalBitmap;	
		}

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
			_specularDot3Shader.shininess = val;
		}
		
		/**
		 * Coefficient for specular light level.
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
			_specularDot3Shader.specular = val;
			
			if (_specular && materials.length < 3)
        		addMaterial(_specularDot3Shader);
   			else if (!_specular && materials.length > 2)
            	removeMaterial(_specularDot3Shader);
		}
        
        /**
        * Returns the bitmapData object being used as the material normal map.
        */
		public function get normalBitmap():BitmapData
		{
			return _normalBitmap;
		}
		
		public function set normalBitmap(val:BitmapData):void
		{
			_normalBitmap = val;
			
			_normalBitmapDirty = true;
		}
        
        /**
        * Returns the bitmap material being used as the material texture.
        */
		public function get textureMaterial():BitmapMaterial
		{
			return _textureMaterial;
		}
		
		/**
		 * Creates a new <code>Dot3BitmapMaterial</code> object.
		 * 
		 * @param	bitmap				The bitmapData object to be used as the material's texture.
		 * @param	normalMap			The bitmapData object to be used as the material's DOT3 map.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function Dot3BitmapMaterial(bitmap:BitmapData, normalBitmap:BitmapData, init:Object = null)
		{
			if (init && init["materials"])
				delete init["materials"];
			
			super(init);
			
			_shininess = ini.getNumber("shininess", 20);
			_specular = ini.getColor("specular", 0xFFFFFF);
			
			_normalBitmap = normalBitmap;
				
        	updateNormalBitmap();
			
			//create new materials
			_textureMaterial = new BitmapMaterial(bitmap, ini);
			_phongShader = new CompositeMaterial({blendMode:BlendMode.MULTIPLY});
			_phongShader.addMaterial(_ambientShader = new AmbientShader({blendMode:BlendMode.ADD}));
			_phongShader.addMaterial(_diffuseDot3Shader = new DiffuseDot3Shader(_renderNormalBitmap, {blendMode:BlendMode.ADD}));
			_specularDot3Shader = new SpecularDot3Shader(_renderNormalBitmap, {shininess:_shininess, specular:_specular, blendMode:BlendMode.ADD});
			
			//add to materials array
			addMaterial(_textureMaterial);
			addMaterial(_phongShader);
			
			if (_specular)
				addMaterial(_specularDot3Shader);
		}
	}
}