package away3d.materials
{
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.primitives.utils.CubeFaces;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.utils.ByteArray;
	
	/**
	 * BitmapData material which creates reflections based on a cube map.
	 * The reflection strength changes based on the refraction of the material and its environment,
	 * as well as the angle of view. This can be used to create water-like reflections.
	 */
	public class FresnelPBMaterial extends SinglePassShaderMaterial
	{
		[Embed(source="../pbks/FresnelShader.pbj", mimeType="application/octet-stream")]
		private var Kernel : Class;
		
		[Embed(source="../pbks/FresnelReflMapShader.pbj", mimeType="application/octet-stream")]
		private var ReflMapKernel : Class;
		
		private var _faces : Array;
		private var _envMapAlpha : Number = 1;
		
		private var _outerRefraction : Number = 1.0008;
		private var _innerRefraction : Number = 1.330;
		private var _fresnelMap : ByteArray;
		
		private var _refractionStrength : Number = 0;
		
		private var _reflectivityMap : BitmapData;
		
		/**
		 * Creates a new FresnelPBMaterial object.
		 * 
		 * @param bitmap The texture to be used for the diffuse shading
		 * @param normalMap An object-space normal map
		 * @param faces An array of equally sized square textures for each face of the cube map. Every value in CubeFaces must be defined as a key to this array and have a BitmapData assigned to it.
		 * @param targetModel The target mesh for which this shader is applied
		 * @param init An initialisation object
		 */
		public function FresnelPBMaterial(bitmap:BitmapData, normalMap:BitmapData, faces : Array, targetModel:Mesh, init:Object=null)
		{
			super(bitmap, normalMap, new Shader(new Kernel()), targetModel, init);
			_useWorldCoords = true;
			_envMapAlpha = ini.getNumber("envMapAlpha", 1);
			_outerRefraction = ini.getNumber("outerRefraction", 1.0008);
			_innerRefraction = ini.getNumber("innerRefraction", 1.330);
			_refractionStrength = ini.getNumber("refractionStrength", 1);
			_faces = faces;
			
			initFresnelMap();
			
			_pointLightShader.data.alpha.value = [ _envMapAlpha ];
			_pointLightShader.data.left.input = faces[CubeFaces.LEFT];
			_pointLightShader.data.right.input = faces[CubeFaces.RIGHT];
			_pointLightShader.data.top.input = faces[CubeFaces.TOP];
			_pointLightShader.data.bottom.input = faces[CubeFaces.BOTTOM];
			_pointLightShader.data.front.input = faces[CubeFaces.FRONT];
			_pointLightShader.data.back.input = faces[CubeFaces.BACK];
			_pointLightShader.data.cubeDim.value = [ faces[CubeFaces.LEFT].width*.5 ];
			_pointLightShader.data.refractionStrength.value = [ _refractionStrength ];
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
				shader.data.left.input = _faces[CubeFaces.LEFT];
				shader.data.right.input = _faces[CubeFaces.RIGHT];
				shader.data.top.input = _faces[CubeFaces.TOP];
				shader.data.bottom.input = _faces[CubeFaces.BOTTOM];
				shader.data.front.input = _faces[CubeFaces.FRONT];
				shader.data.back.input = _faces[CubeFaces.BACK];
				shader.data.cubeDim.value = [ _faces[CubeFaces.LEFT].width*.5 ];
				shader.data.normalTransformation.value = _pointLightShader.data.normalTransformation.value;
				shader.data.positionTransformation.value = _pointLightShader.data.positionTransformation.value;
				shader.data.positionMap.input = _positionMap;
				shader.data.normalMap.input = _normalMap;
				shader.data.fresnelMap.input = _fresnelMap;
				shader.data.fresnelMap.width = 256;
				shader.data.fresnelMap.height = 1;
				_pointLightShader = shader;
			} 
			_reflectivityMap = value;
		}
		
		/**
		 * The maximum amount of refraction to be performed on the diffuse texture, used to simulate water
		 */
		public function get refractionStrength() : Number
		{
			return _refractionStrength;
		}
		
		public function set refractionStrength(value : Number) : void
		{
			_refractionStrength = value;
			_pointLightShader.data.refractionStrength.value = [ _refractionStrength ];
		}
		
		private function initFresnelMap() : void
		{
			var i : int = 256;
			var dot : Number;
			var angle : Number;
			var refrAngle : Number;
			var fres : Number;
			var t1 : Number;
			var t2 : Number;
			
			_fresnelMap = new ByteArray();
			
			while (i--) {
				angle = Math.acos(i/256);
				
				// snel's law: n1*sin(a1) = n2*sin(a2)
				refrAngle = Math.asin(Math.sin(angle)*_outerRefraction/_innerRefraction);
				
				t1 = Math.sin(angle-refrAngle)/Math.sin(angle+refrAngle);
				t2 = Math.tan(angle-refrAngle)/Math.tan(angle+refrAngle);
				
				fres = t1*t1+t2*t2;
				if (fres > 1.0) fres = 1.0;
				else if (fres < 0.0) fres = 0.0;
				_fresnelMap.writeFloat(fres);
				_fresnelMap.writeFloat(fres);
				_fresnelMap.writeFloat(fres);
			}
			
			_pointLightShader.data.fresnelMap.input = _fresnelMap;
			_pointLightShader.data.fresnelMap.width = 256;
			_pointLightShader.data.fresnelMap.height = 1;
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