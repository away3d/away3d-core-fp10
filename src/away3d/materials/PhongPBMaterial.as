package away3d.materials
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.light.*;
	import away3d.core.math.*;
	
	import flash.display.*;

	use namespace arcane;
	
	/**
	 * Bitmap material with per-texel phong shading.
	 */
	public class PhongPBMaterial extends SinglePassShaderMaterial
	{
		[Embed(source="../pbks/PhongNormalMapShader.pbj", mimeType="application/octet-stream")]
		private var NormalKernel : Class;
		
		[Embed(source="../pbks/PhongNormalSpecularShader.pbj", mimeType="application/octet-stream")]
		private var SpecularKernel : Class;
		
		private var _objectLightPos : Number3D = new Number3D();
		private var _objectViewPos : Number3D = new Number3D();
		
		private var _specular : Number;
		
		private var _specularMap : BitmapData;
		
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
			
			_specularMap = specularMap;
			
			if (specularMap) {
				shader = new Shader(new SpecularKernel());
				shader.data.specularMap.input = specularMap;
			}
			else
				shader = new Shader(new NormalKernel());
			shader.precisionHint = ShaderPrecision.FAST;
			
			super(bitmap, normalMap, shader, targetModel, init);
			
			gloss = ini.getNumber("gloss", 10);
			specular = ini.getNumber("specular", 1);
		}
		
		public function get specularMap() : BitmapData
		{
			return _specularMap;
		}
		
		public function set specularMap(value : BitmapData) : void
		{
			var shader : Shader;
			if (_specularMap) {
				if (value)
					_pointLightShader.data.specularMap.input = value;
				else {
					shader = new Shader(new NormalKernel());
					shader.data.phongComponents.value[1] = gloss;
					shader.data.normalMap.input = _normalMap;
					shader.data.positionMap.input = _positionMap;
					shader.data.positionTransformation.value = _pointLightShader.data.positionTransformation.value;
					shader.precisionHint = ShaderPrecision.FAST;
					_pointLightShader = shader;
				}
			}
			else if (value) {
				shader = new Shader(new SpecularKernel());
				shader.data.phongComponents.value[1] = gloss;
				shader.data.specularMap.input = value;
				shader.data.normalMap.input = _normalMap;
				shader.data.positionMap.input = _positionMap;
				shader.data.positionTransformation.value = _pointLightShader.data.positionTransformation.value;
				shader.precisionHint = ShaderPrecision.FAST;
				_pointLightShader = shader;
			}
			_specularMap = value;
		}
		
		/**
		 * The gloss component of the specular highlight. Higher numbers will result in a smaller and sharper highlight.
		 */
		public function get gloss() : Number
		{
			return _pointLightShader.data.phongComponents.value[1];
		}
		
		public function set gloss(value : Number) : void
		{
			_pointLightShader.data.phongComponents.value[1] = value;
		}
		
		/**
		 * The strength of the specular highlight
		 */
		public function get specular() : Number
		{
			return _specular;
		}
		
		public function set specular(value : Number) : void
		{
			_specular = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updatePixelShader(source:Object3D, view:View3D):void
		{
			var invSceneTransform : MatrixAway3D = _mesh.inverseSceneTransform;
			var point : PointLight;
			var ambient : AmbientLight;
			var diffuseStr : Number;
			var ar : Number = 0,
				ag : Number = 0,
				ab : Number = 0;

			_objectViewPos.transform(view.camera.position, invSceneTransform);
			_pointLightShader.data.viewPos.value = [ _objectViewPos.x, _objectViewPos.y, _objectViewPos.z ];
			
			// calculate ambient colour
			for each (ambient in source.lightarray.ambients) {
				ar += ambient.red/255;
				ag += ambient.green/255;
				ab += ambient.blue/255;
			}
			
			if (ar >= 0xff) ar = 1;
			else ar /= 0xff;
			if (ag >= 0xff) ag = 1;
			else ag /= 0xff; 
			if (ab >= 0xff) ab = 1;
			else ab /= 0xff;
			
			_pointLightShader.data.ambientColor.value = [ar, ag, ab];
			
			// use first point light
			if (source.lightarray.points.length > 0) {
				point = source.lightarray.points[0];
				diffuseStr = point.diffuse;
				_objectLightPos.transform(point.position, invSceneTransform);
				_pointLightShader.data.lightPosition.value = [ _objectLightPos.x, _objectLightPos.y, _objectLightPos.z ];
				_pointLightShader.data.lightRadiusFalloff.value[0] = point.radius;
				
				if (point.fallOff == Number.POSITIVE_INFINITY || point.fallOff == Number.NEGATIVE_INFINITY)
					_pointLightShader.data.lightRadiusFalloff.value[1] = -1;
				else
					_pointLightShader.data.lightRadiusFalloff.value[1] = point.fallOff - point.radius;

				_pointLightShader.data.objectScale.value = [ _mesh.scaleX, _mesh.scaleY, _mesh.scaleZ ];
				_pointLightShader.data.specularColor.value = [ point.red/255, point.green/255, point.blue/255 ];
				_pointLightShader.data.phongComponents.value[0] = _specular * point.specular;
				_pointLightShader.data.diffuseColor.value = [ point.red*diffuseStr/255, point.green*diffuseStr/255, point.blue*diffuseStr/255 ];
        	}
        	else {
        		_pointLightShader.data.diffuseColor.value = [ 0, 0, 0 ];
        		_pointLightShader.data.specularColor.value = [ 0, 0, 0 ];
        	}
		}
	}
}