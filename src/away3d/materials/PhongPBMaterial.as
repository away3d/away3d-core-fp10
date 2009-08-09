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
	 * Bitmap material with per-texel phong shading.
	 */
	public class PhongPBMaterial extends PixelShaderMaterial
	{
		[Embed(source="/../pbj/PhongNormalMapShader.pbj", mimeType="application/octet-stream")]
		private var NormalKernel : Class;
		
		[Embed(source="/../pbj/PhongNormalSpecularShader.pbj", mimeType="application/octet-stream")]
		private var SpecularKernel : Class;
		
		private var _specularColor : uint;
		
		/**
		 * Creates a new PhongPBMaterial object.
		 * 
		 * @param bitmap The texture to be used for the diffuse shading
		 * @param normalMap An object-space normal map
		 * @param targetModel The target mesh for which this shader is applied
		 * @param specularMap An optional specular map BitmapData, which modulates the specular reflections
		 * @param init An initialisation object
		 */
		public function PhongPBMaterial(bitmap:BitmapData, normalMap:BitmapData, targetModel:Mesh, specularMap : BitmapData = null, init:Object=null)
		{
			var shader : Shader;
			if (specularMap) {
				shader = new Shader(new SpecularKernel());
				shader.data.specularMap.input = specularMap;
			}
			else shader = new Shader(new NormalKernel());
			super(bitmap, normalMap, shader, targetModel, init);
			
			gloss = ini.getNumber("gloss", 10);
			specular = ini.getNumber("specular", 1);
			specularColor = ini.getInt("specularColor", 0xffffff);
		}
		
		/**
		 * The gloss component of the specular highlight. Higher numbers will result in a smaller and sharper highlight.
		 */
		public function get gloss() : Number
		{
			return _pixelShader.data.gloss.value[0];
		}
		
		public function set gloss(value : Number) : void
		{
			_pixelShader.data.gloss.value[0] = value;
		}
		
		/**
		 * The strength of the specular highlight
		 */
		public function get specular() : Number
		{
			return _pixelShader.data.specular.value[0];
		}
		
		public function set specular(value : Number) : void
		{
			_pixelShader.data.specular.value[0] = value;
		}
		
		/**
		 * The colour of the specular highlight.
		 */
		public function get specularColor() : uint
		{
			return _specularColor;
		}
		
		public function set specularColor(value : uint) : void
		{
			_specularColor = value;
			_pixelShader.data.specularColor.value = [ 	((value & 0xff0000) >> 16)/0xff,
														((value & 0x00ff00) >> 8)/0xff,
														(value & 0x0000ff)/0xff,
													];
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