package away3d.materials
{
	import away3d.arcane;
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.light.AmbientLight;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shader;

	use namespace arcane;
	
	internal class MultiPassShaderMaterial extends PixelShaderMaterial
	{
		protected var _specularColor : uint;
		protected var _ambient : uint = 0;
		protected var _directionals : Array;
		protected var _points : Array;
		
		protected var _directionalLightShader : Shader;
		protected var _lightMap : BitmapData;
		protected var _shaderBlendMode : String = BlendMode.HARDLIGHT;
		protected var _useAmbient : Boolean = true;
		
		
		/**
	 	 * The base class for Pixel Bender texel shader materials that support multiple and directional lights
	 	 */
		public function MultiPassShaderMaterial(bitmap:BitmapData, normalMap:BitmapData, pointShader:Shader, directionalShader:Shader, targetModel:Mesh, init:Object=null)
		{
			super(bitmap, normalMap, pointShader, targetModel, init);
			_directionalLightShader = directionalShader;
			_lightMap = new BitmapData(bitmap.width, bitmap.height, false);
			_pointLightShader.data.lightMap.input = _lightMap;
			_directionalLightShader.data.lightMap.input = _lightMap;
			_directionalLightShader.data.positionTransformation.value = _pointLightShader.data.positionTransformation.value;
			_directionalLightShader.data.normalMap.input = _normalMap;
			_directionalLightShader.data.positionMap.input = _positionMap;
			
		}
		
		override public function set normalMap(value:BitmapData):void
		{
			super.normalMap = value;
			_directionalLightShader.data.normalMap.input = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateRenderBitmap():void
		{
			_bitmapDirty = false; 
        	
        	super.updateRenderBitmap();
	        
			_lightMap.fillRect(_lightMap.rect, _ambient);
			
			renderLightMap();
			
			_renderBitmap.draw(_lightMap, null, null, _shaderBlendMode);
	        invalidateFaces();
	        
		}
		
		/**
		 * Renders the multiple passes to the light map
		 */
		protected function renderLightMap() : void
		{
			// must be overridden
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updatePixelShader(source:Object3D, view:View3D):void
		{
			var ar : Number = 0,
				ag : Number = 0,
				ab : Number = 0;
			var ambient : AmbientLight;
			// calculate ambient colour
			
			if (_useAmbient) {
				for each (ambient in source.lightarray.ambients) {
					ar += ambient.red;
					ag += ambient.green;
					ab += ambient.blue;
				}
				
				if (ar >= 0xff) ar = 0xff;
				if (ag >= 0xff) ag = 0xff;
				if (ab >= 0xff) ab = 0xff;
				
				_ambient = (ar << 16) | (ag << 8) | ab;
			}
			
			_points = source.lightarray.points;
			_directionals = source.lightarray.directionals;
			
			_bitmapDirty = true;
			
			super.updatePixelShader(source, view);
		}
		
	}
}