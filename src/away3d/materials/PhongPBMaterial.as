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
	 * Bitmap material with per-texel phong shading.
	 */
	public class PhongPBMaterial extends SinglePassShaderMaterial
	{
		[Embed(source="../pbks/PhongNormalMapShader.pbj", mimeType="application/octet-stream")]
		private var NormalKernel : Class;
		
		[Embed(source="../pbks/PhongNormalSpecularShader.pbj", mimeType="application/octet-stream")]
		private var SpecularKernel : Class;
		
		private var _objectLightPos : Vector3D = new Vector3D();
		private var _objectViewPos : Vector3D = new Vector3D();
		
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
			var invSceneTransform : Matrix3D = _mesh.inverseSceneTransform;
			var point : PointLight3D;
			var ambient : AmbientLight3D;
			var diffuseStr : Number;
			var ar : Number = 0,
				ag : Number = 0,
				ab : Number = 0;

			_objectViewPos = invSceneTransform.transformVector(view.camera.position);
			_pointLightShader.data.viewPos.value = [ _objectViewPos.x, _objectViewPos.y, _objectViewPos.z ];
			
			// calculate ambient colour
			for each (ambient in source.scene.ambientLights) {
				ar += ambient._red;
				ag += ambient._green;
				ab += ambient._blue;
			}
			
			if (ar >= 0xff) ar = 1;
			else ar /= 0xff;
			if (ag >= 0xff) ag = 1;
			else ag /= 0xff; 
			if (ab >= 0xff) ab = 1;
			else ab /= 0xff;
			
			_pointLightShader.data.ambientColor.value = [ar, ag, ab];
			
			// use first point light
			if (source.scene.pointLights.length > 0) {
				point = source.scene.pointLights[0];
				diffuseStr = point.diffuse * point.brightness;
				_objectLightPos = invSceneTransform.transformVector(point.position);
				_pointLightShader.data.lightPosition.value = [ _objectLightPos.x, _objectLightPos.y, _objectLightPos.z ];
				_pointLightShader.data.lightRadiusFalloff.value[0] = point.radius;
				
				if (point.fallOff == Number.POSITIVE_INFINITY || point.fallOff == Number.NEGATIVE_INFINITY)
					_pointLightShader.data.lightRadiusFalloff.value[1] = -1;
				else
					_pointLightShader.data.lightRadiusFalloff.value[1] = point.fallOff - point.radius;

				_pointLightShader.data.objectScale.value = [ _mesh.scaleX, _mesh.scaleY, _mesh.scaleZ ];
				_pointLightShader.data.specularColor.value = [point._red, point._green, point._blue];
				_pointLightShader.data.phongComponents.value[0] = _specular * point.specular * point.brightness;
				_pointLightShader.data.diffuseColor.value = [ point._red*diffuseStr, point._green*diffuseStr, point._blue*diffuseStr ];
        	}
        	else {
        		_pointLightShader.data.diffuseColor.value = [ 0, 0, 0 ];
        		_pointLightShader.data.specularColor.value = [ 0, 0, 0 ];
        	}
		}
	}
}