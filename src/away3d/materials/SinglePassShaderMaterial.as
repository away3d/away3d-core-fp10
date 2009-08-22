package away3d.materials
{
	import away3d.arcane;
	import away3d.core.base.Mesh;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	
	use namespace arcane;
	
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
	        
	        _pointLightShader.data.diffuse.input = _renderBitmap;
	        shaderJob = new ShaderJob(_pointLightShader, _renderBitmap);
	        shaderJob.start(true);
	        invalidateFaces();
        }
	}
}