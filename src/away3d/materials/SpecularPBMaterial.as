package away3d.materials
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.lights.*;
	
	import flash.display.*;
	import flash.geom.*;

	use namespace arcane;
	
	/**
	 * Bitmap material with per-texel specular-only shading.
	 */
	public class SpecularPBMaterial extends SinglePassShaderMaterial
	{
		[Embed(source="../pbks/SpecularNormalMapShader.pbj", mimeType="application/octet-stream")]
		private var NormalKernel : Class;
		
		[Embed(source="../pbks/SpecularNormalSpecularShader.pbj", mimeType="application/octet-stream")]
		private var SpecularKernel : Class;
		
		private var _objectLightPos : Vector3D = new Vector3D();
		private var _objectViewPos : Vector3D = new Vector3D();
		
		private var _specular : Number;
		
		private var _specularMap : BitmapData;
		
		/**
		 * Creates a new SpecularPBMaterial object.
		 * 
		 * @param bitmap The texture to be used for the diffuse shading
		 * @param normalMap An object-space normal map
		 * @param targetModel The target mesh for which this shader is applied
		 * @param specularMap An optional specular map BitmapData, which modulates the specular reflections
		 * @param init An initialisation object
		 */
		public function SpecularPBMaterial(bitmap:BitmapData, normalMap:BitmapData, targetModel:Mesh, specularMap : BitmapData = null, init:Object=null)
		{
			var shader : Shader;
			
			_specularMap = specularMap;
			
			if (specularMap) {
				shader = new Shader(new SpecularKernel());
				shader.data.specularMap.input = specularMap;
				_specularMap = specularMap;
			}
			else shader = new Shader(new NormalKernel());
			shader.precisionHint = ShaderPrecision.FAST;
			
			super(bitmap, normalMap, shader, targetModel, init);
			
			gloss = ini.getNumber("gloss", 10);
			_specular = ini.getNumber("specular", 1);
		}
		
		/**
		 * An optional specular map BitmapData, which modulates the specular reflections
		 */
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
			var invSceneTransform : Matrix3D = _mesh.inverseSceneTransform;
			var point : PointLight3D;

			_objectViewPos = invSceneTransform.transformVector(view.camera.position);
			_pointLightShader.data.viewPos.value = [ _objectViewPos.x, _objectViewPos.y, _objectViewPos.z ];
			
			// use first point light
			if (source.scene.pointLights.length > 0) {
				point = source.scene.pointLights[0];
				_objectLightPos = invSceneTransform.transformVector(point.position);
				_pointLightShader.data.lightPosition.value = [ _objectLightPos.x, _objectLightPos.y, _objectLightPos.z ];
				_pointLightShader.data.lightRadiusFalloff.value[0] = point.radius;
				_pointLightShader.data.phongComponents.value[0] = _specular*point.specular*point.brightness;
				_pointLightShader.data.specularColor.value = [ point._red, point._green, point._blue ];
				if (point.fallOff == Number.POSITIVE_INFINITY || point.fallOff == Number.NEGATIVE_INFINITY)
					_pointLightShader.data.lightRadiusFalloff.value[1] = -1;
				else
					_pointLightShader.data.lightRadiusFalloff.value[1] = point.fallOff - point.radius;

				_pointLightShader.data.objectScale.value = [ _mesh.scaleX, _mesh.scaleY, _mesh.scaleZ ];
        	}
		}
	}
}