package away3d.materials
{
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.primitives.utils.CubeFaces;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderPrecision;
	import flash.utils.ByteArray;
	
	/**
	 * BitmapData material which creates reflections based on a cube map.
	 * The reflection strength changes based on the refraction of the material and its environment,
	 * as well as the angle of view. This can be used to create water-like reflections.
	 */
	public class GlassMaterial extends SinglePassShaderMaterial
	{
		[Embed(source="../pbks/GlassShader.pbj", mimeType="application/octet-stream")]
		private var KernelBasic : Class;

		[Embed(source="../pbks/GlassShaderChrDisp.pbj", mimeType="application/octet-stream")]
		private var KernelChroma : Class;
		
		private var _envMapAlpha : Number = 1;
		
		private var _outerRefraction : Number = 1.0002926;
		private var _innerRefraction : Number = 1.330;
		private var _fresnelMap : BitmapData;
		private var _glassColor : uint;
		private var _dispersionR : Number = 1;
		private var _dispersionG : Number = 1;
		private var _dispersionB : Number = 1;
		private var _chromaticDispersion : Boolean;
		private var _exponent : Number = 5;
		private var _fresnelMapDirty : Boolean = true;

		/**
		 * Creates a new GlassMaterial object.
		 * 
		 * @param normalMap An object-space normal map
		 * @param envMap The spherical environment map used for reflections
		 * @param targetModel The target mesh for which this shader is applied
		 * @param init An initialisation object
		 */                                                     
		public function GlassMaterial(normalMap:BitmapData, envMap : BitmapData, targetModel:Mesh, chromaticDispersion : Boolean = false, init:Object=null)
		{
			var kernel : ByteArray = chromaticDispersion ? new KernelChroma() : new KernelBasic();
			super(new BitmapData(normalMap.width, normalMap.height, false), normalMap, new Shader(kernel), targetModel, init);
			_useWorldCoords = true;         
			_envMapAlpha = ini.getNumber("envMapAlpha", 1);
			_outerRefraction = ini.getNumber("outerRefraction", 1.0008);
			_innerRefraction = ini.getNumber("innerRefraction", 1.330);
			_dispersionR = ini.getNumber("dispersionR", 1);
			_dispersionG = ini.getNumber("dispersionG", .95);
			_dispersionB = ini.getNumber("dispersionB", .9);
			_exponent = ini.getNumber("exponent", 5);
			_chromaticDispersion = chromaticDispersion;
			glassColor = ini.getInt("glassColor", 0xffffff);

			_pointLightShader.data.alpha.value = [ _envMapAlpha ];
			_pointLightShader.data.envMap.input = envMap;
			_pointLightShader.data.envMapDim.value = [ envMap.width*.5 ];
			_pointLightShader.data.refractionRatio.value = [ _outerRefraction/_innerRefraction ];
			if (chromaticDispersion)
				_pointLightShader.data.dispersion.value = [ _dispersionR, _dispersionG, _dispersionB ];
		}

		public function get glassColor() : uint
		{
			return _glassColor;
		}

		public function set glassColor(value : uint) : void
		{
			var r : Number = ((value >> 16) & 0xff)/0xff;
			var g : Number = ((value >> 8) & 0xff)/0xff;
			var b : Number = (value & 0xff)/0xff;
			_glassColor = value;
			_pointLightShader.data.color.value = [ r, g, b ];
		}

		/**
		 * The scale of dispersion for the red channel. For best results, use value close to but lower than 1.
		 */
		public function get dispersionR() : Number
		{
			return _dispersionR;
		}

		public function set dispersionR(value : Number) : void
		{
			if (_chromaticDispersion) _pointLightShader.data.dispersion.value[0] = value;
			_dispersionR = value;
		}

		/**
		 * The scale of dispersion for the green channel. For best results, use value close to but lower than 1.
		 */
		public function get dispersionG() : Number
		{
			return _dispersionG;
		}

		public function set dispersionG(value : Number) : void
		{
			if (_chromaticDispersion) _pointLightShader.data.dispersion.value[1] = value;
			_dispersionG = value;
		}

		/**
		 * The scale of dispersion for the blue channel. For best results, use value close to but lower than 1. 
		 */
		public function get dispersionB() : Number
		{
			return _dispersionB;
		}

		public function set dispersionB(value : Number) : void
		{
			if (_chromaticDispersion) _pointLightShader.data.dispersion.value[2] = value;
			_dispersionB = value;
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

			if (!_fresnelMap) _fresnelMap = new BitmapData(256, 1, false, 1);

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