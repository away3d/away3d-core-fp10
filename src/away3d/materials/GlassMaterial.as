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
		private var Kernel : Class;
		
		private var _envMapAlpha : Number = 1;
		
		private var _outerRefraction : Number = 1.0002926;
		private var _innerRefraction : Number = 1.330;
		private var _fresnelMap : BitmapData;
		private var _refractionMap : BitmapData;
		private var _glassColor : uint;

		
		/**
		 * Creates a new GlassMaterial object.
		 * 
		 * @param normalMap An object-space normal map
		 * @param envMap The spherical environment map used for reflections
		 * @param targetModel The target mesh for which this shader is applied
		 * @param init An initialisation object
		 */                                                     
		public function GlassMaterial(normalMap:BitmapData, envMap : BitmapData, targetModel:Mesh, init:Object=null)
		{
			super(new BitmapData(normalMap.width, normalMap.height, false), normalMap, new Shader(new Kernel()), targetModel, init);
			_useWorldCoords = true;         
			_envMapAlpha = ini.getNumber("envMapAlpha", 1);
			_outerRefraction = ini.getNumber("outerRefraction", 1.0008);
			_innerRefraction = ini.getNumber("innerRefraction", 1.330);
			glassColor = ini.getInt("glassColor", 0xffffff); 

			initFresnelMap();
			
			_pointLightShader.data.alpha.value = [ _envMapAlpha ];
			_pointLightShader.data.envMap.input = envMap;
			_pointLightShader.data.envMapDim.value = [ envMap.width*.5 ];
			_pointLightShader.data.refractionRatio.value = [ _outerRefraction/_innerRefraction ];
			_pointLightShader.precisionHint = ShaderPrecision.FAST;
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

		private function initFresnelMap() : void
		{
			var i : int = 256;
			var dot : Number;
			var angle : Number;
			var refrAngle : Number;
			var fres : Number;
			var t1 : Number;
			var t2 : Number;
			var fresVec : Vector.<uint> = new Vector.<uint>(256);
			var refrVec : Vector.<uint> = new Vector.<uint>(256);

			// TO DO, see if can be changed to BMD
			_fresnelMap = new BitmapData(256, 1, false, 1);

			while (i--) {
				angle = Math.acos(i/256);
				
				// snel's law: n1*sin(a1) = n2*sin(a2)
				refrAngle = Math.asin(Math.sin(angle)*_outerRefraction/_innerRefraction);
				
				t1 = Math.sin(angle-refrAngle)/Math.sin(angle+refrAngle);
				t2 = Math.tan(angle-refrAngle)/Math.tan(angle+refrAngle);
				                                                                          
				fres = t1*t1+t2*t2;
				if (fres > 1.0) fres = 1.0;
				else if (fres < 0.0) fres = 0.0;
				fresVec[256-i] = 0xff000000 | Math.round(fres*0xff) << 16;
				refrVec[256-i] = 0xff000000 | Math.round((refrAngle*.5 + .5)*0xff);
			}
			                                 
			_fresnelMap.setVector(_fresnelMap.rect, fresVec);

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
			var camera : Camera3D = view.camera;
			_pointLightShader.data.viewPos.value = [ camera.x, camera.y, camera.z ];
			super.updatePixelShader(source, view);
		}
	}
}