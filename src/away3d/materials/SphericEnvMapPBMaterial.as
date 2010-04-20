package away3d.materials
{
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	
	/**
	 * BitmapData material which creates reflections based on a spherical map.
	 */
	public class SphericEnvMapPBMaterial extends SinglePassShaderMaterial
	{
		[Embed(source="../pbks/SphericEnvNormalMapShader.pbj", mimeType="application/octet-stream")]
		private var Kernel : Class;
		
		[Embed(source="../pbks/SphericEnvReflMapShader.pbj", mimeType="application/octet-stream")]
		private var ReflMapKernel : Class;
		
		protected var _envMap : BitmapData;
		private var _envMapAlpha : Number = 1;
		
		private var _reflectivityMap : BitmapData;
		
		/**
		 * Creates a new SphericEnvMapPBMaterial object.
		 * 
		 * @param bitmap The texture to be used for the diffuse shading
		 * @param normalMap An object-space normal map
		 * @param envMap The environment map to be reflected
		 * @param targetModel The target mesh for which this shader is applied
		 * @param init An initialisation object
		 */
		public function SphericEnvMapPBMaterial(bitmap:BitmapData, normalMap:BitmapData, envMap : BitmapData, targetModel:Mesh, init:Object=null)
		{
			super(bitmap, normalMap, new Shader(new Kernel()), targetModel, init);
			
			_envMapAlpha = ini.getNumber("envMapAlpha", 1);
			_envMap = envMap;
			_useWorldCoords = true;                                       
			_pointLightShader.data.alpha.value = [ _envMapAlpha ];
			_pointLightShader.data.envMap.input = envMap;
			_pointLightShader.data.envMapDim.value = [ envMap.width*.5 ];
		}

		/**
		 * A texture map that indicates the reflection amount for each texel
		 */
		public function get reflectivityMap() : BitmapData
		{
			return _reflectivityMap;
		}
		
		public function set reflectivityMap(value : BitmapData) : void
		{
			var copyNeeded : Boolean;
			var shader : Shader;
			
			if (!_reflectivityMap && value) {
				shader = new Shader(new ReflMapKernel());
				copyNeeded = true;
			}
			else if (_reflectivityMap && !value) {
				shader = new Shader(new Kernel());
				copyNeeded = true;
			}
			
			if (value) shader.data.reflectivityMap.input = value;
			
			if (copyNeeded) {
				shader.data.alpha.value = [ _envMapAlpha ];
				shader.data.envMap.input = _pointLightShader.data.envMap.input;
				shader.data.normalTransformation.value = _pointLightShader.data.normalTransformation.value;
				shader.data.positionTransformation.value = _pointLightShader.data.positionTransformation.value;
				shader.data.positionMap.input = _positionMap;
				shader.data.normalMap.input = _normalMap;
				_pointLightShader = shader;
			} 
			_reflectivityMap = value;
		}
		
		/**
		 * The opacity of the environment map, ie: how reflective the surface is. 1 is a perfect mirror.
		 */
		public function get envMapAlpha() : Number
		{
			return _envMapAlpha;
		}
		
		public function set envMapAlpha(value : Number) : void
		{
			_envMapAlpha = value;
			_pointLightShader.data.alpha.value = [ value ];
		}
		
		override protected function updatePixelShader(source:Object3D, view:View3D):void
		{
			_pointLightShader.data.viewPos.value = [ view.camera.x, view.camera.y, view.camera.z ];
			super.updatePixelShader(source, view);
		}
	}
}