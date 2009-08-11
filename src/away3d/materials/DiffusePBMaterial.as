package away3d.materials
{
	import away3d.arcane;
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.light.AmbientLight;
	import away3d.core.light.PointLight;
	
	import flash.display.BitmapData;
	import flash.display.Shader;

	use namespace arcane;
	
	/**
	 * Bitmap material with per-texel diffuse (Lambert) shading.
	 */
	public class DiffusePBMaterial extends PixelShaderMaterial
	{
		[Embed(source="../pbks/LambertNormalMapShader.pbj", mimeType="application/octet-stream")]
		private var Kernel : Class;
		
		/**
		 * Creates a new DiffusePBMaterial object.
		 * 
		 * @param bitmap The texture to be used for the diffuse shading
		 * @param normalMap An object-space normal map
		 * @param targetModel The target mesh for which this shader is applied
		 * @param init An initialisation object
		 */
		public function DiffusePBMaterial(bitmap:BitmapData, normalMap:BitmapData, targetModel:Mesh, init:Object=null)
		{
			super(bitmap, normalMap, new Shader(new Kernel()), targetModel, init);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateMaterial(source:Object3D, view:View3D):void
		{
			var point : PointLight;
			var ambient : AmbientLight;
			var ar : Number = 0,
				ag : Number = 0,
				ab : Number = 0;
			
			// calculate ambient colour
			for each (ambient in source.lightarray.ambients) {
				ar += ambient.red;
				ag += ambient.green;
				ab += ambient.blue;
			}
			
			if (ar >= 0xff) ar = 1;
			else ar /= 0xff;
			if (ag >= 0xff) ag = 1;
			else ag /= 0xff; 
			if (ab >= 0xff) ab = 1;
			else ab /= 0xff;
			
			_pixelShader.data.ambientColor.value = [ar, ag, ab];
			
			// use first point light
			if (source.lightarray.points.length > 0) {
				point = source.lightarray.points[0];
        		_pixelShader.data.lightPosition.value = [ point.light.x, point.light.y, point.light.z ];
        		_pixelShader.data.diffuseColor.value = [ point.red, point.green, point.blue ];
        	}
        	else _pixelShader.data.diffuseColor.value = [ 0, 0, 0 ];
        	
        	_bitmapDirty = true;
        	
        	super.updateMaterial(source, view);
		}
	}
}