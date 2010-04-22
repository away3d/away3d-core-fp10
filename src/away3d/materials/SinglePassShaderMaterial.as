package away3d.materials
{
	import away3d.arcane;
	import away3d.core.base.Mesh;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	
	use namespace arcane;
	
	/**
	 * The base class for Pixel Bender texel shader materials which use a single point light (the first to be added to the scene).
	 */
	internal class SinglePassShaderMaterial extends PixelShaderMaterial
	{
		public function SinglePassShaderMaterial(bitmap:BitmapData, normalMap:BitmapData, pixelShader:Shader, targetModel:Mesh, init:Object=null)
		{
			super(bitmap, normalMap, pixelShader, targetModel, init);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateRenderBitmap():void
        {
        	var shaderJob : ShaderJob;
        	_bitmapDirty = false; 
        	
        	super.updateRenderBitmap();

			if (_pointLightShader.data.hasOwnProperty("diffuse"))
	        	_pointLightShader.data.diffuse.input = _renderBitmap;
	        shaderJob = new ShaderJob(_pointLightShader, _renderBitmap);
	        shaderJob.start(true);
	        invalidateFaces();
        }
	}
}