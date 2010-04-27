package away3d.materials
{
	import away3d.cameras.Camera3D;
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
		
		private var _envMapAlpha : Number = 1;
		
		private var _outerRefraction : Number = 1.0002926;
		private var _innerRefraction : Number = 1.330;
		private var _fresnelMap : BitmapData;
		private var _fresnelMapDirty : Boolean = true;
		private var _exponent : Number = 5;

		private var _refractionStrength : Number = 0;
		
		/**
		 * Creates a new FresnelPBMaterial object.
		 * 
		 * @param bitmap The texture to be used for the diffuse shading
		 * @param normalMap An object-space normal map
		 * @param envMap The spherical environment map used for reflections
		 * @param targetModel The target mesh for which this shader is applied
		 * @param init An initialisation object
		 */                                                     
		public function FresnelPBMaterial(bitmap:BitmapData, normalMap:BitmapData, envMap : BitmapData, targetModel:Mesh, init:Object=null)
		{
			super(bitmap, normalMap, new Shader(new Kernel()), targetModel, init);
			_useWorldCoords = true;         
			_envMapAlpha = ini.getNumber("envMapAlpha", 1);
			_outerRefraction = ini.getNumber("outerRefraction", 1.0008);
			_innerRefraction = ini.getNumber("innerRefraction", 1.330);
			_refractionStrength = ini.getNumber("refractionStrength", 1);
			_exponent = ini.getNumber("exponent", 5);

			_pointLightShader.data.alpha.value = [ _envMapAlpha ];
			_pointLightShader.data.envMap.input = envMap;
			_pointLightShader.data.envMapDim.value = [ envMap.width*.5 ];
			_pointLightShader.data.refractionStrength.value = [ _refractionStrength ];
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

		/**
		 * The refractive index of the outer medium (where the view ray starts)
		 */
		public function get outerRefraction() : Number
		{
			return _outerRefraction;
		}

		public function set outerRefraction(value : Number) : void
		{
			_outerRefraction = value;
			_fresnelMapDirty = true;
		}

		/**
		 * The refractive index of the inner medium (ie the material itself)
		 */
		public function get innerRefraction() : Number
		{
			return _innerRefraction;
		}

		public function set innerRefraction(value : Number) : void
		{
			_innerRefraction = value;
			_fresnelMapDirty = true;
		}

		/**
		 * The exponent of the calculated fresnel term. Lower values will only show reflections at steeper view angles.
		 */
		public function get exponent() : Number
		{
			return _exponent;
		}

		public function set exponent(value : Number) : void
		{
			_exponent = value;
			_fresnelMapDirty = true;
		}

		private function initFresnelMap() : void
		{
			var i : int = 256;
			var fres : Number;
			var vec : Vector.<uint> = new Vector.<uint>(256);
			var dot : Number;

			var r0 : Number = (_outerRefraction-_innerRefraction)*(_outerRefraction-_innerRefraction)/((_outerRefraction+_innerRefraction)*(_outerRefraction+_innerRefraction));

			if(!_fresnelMap) _fresnelMap = new BitmapData(256, 1, false, 1);

			while (i--) {
				// view vector is inverted in pixel shader (and so is dot product), hence no 1-i/256 as is usual
				dot = i/256;
				fres = r0+(1-r0)*Math.pow(dot, _exponent);

				if (fres > 1.0) fres = 1.0;
				else if (fres < 0.0) fres = 0.0;

				vec[i] = int(fres*0xff) << 16;
			}

			_fresnelMap.setVector(_fresnelMap.rect, vec);

			_pointLightShader.data.fresnelMap.input = _fresnelMap;
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
			if (_fresnelMapDirty) {
				initFresnelMap();
				_fresnelMapDirty = false;
			}

			var camera : Camera3D = view.camera;
			_pointLightShader.data.viewPos.value = [ camera.x, camera.y, camera.z ];
			super.updatePixelShader(source, view);
		}
	}
}