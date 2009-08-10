package away3d.materials
{
	import away3d.core.base.Mesh;
	import away3d.primitives.utils.CubeFaces;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	
	/**
	 * BitmapData material which creates reflections based on a cube map.
	 */
	public class CubicEnvMapPBMaterial extends PixelShaderMaterial
	{
		[Embed(source="../pbks/CubicEnvNormalMapShader.pbj", mimeType="application/octet-stream")]
		private var Kernel : Class;
		
		private var _faces : Array;
		private var _envMapAlpha : Number = 1;
		
		/**
		 * Creates a new CubicEnvMapPBMaterial object.
		 * 
		 * @param bitmap The texture to be used for the diffuse shading
		 * @param normalMap An object-space normal map
		 * @param faces An array of equally sized square textures for each face of the cube map. Every value in CubeFaces must be defined as a key to this array and have a BitmapData assigned to it.
		 * @param targetModel The target mesh for which this shader is applied
		 * @param init An initialisation object
		 */
		public function CubicEnvMapPBMaterial(bitmap:BitmapData, normalMap:BitmapData, faces : Array, targetModel:Mesh, init:Object=null)
		{
			super(bitmap, normalMap, new Shader(new Kernel()), targetModel, init);
			
			_envMapAlpha = ini.getNumber("envMapAlpha", 1);
			
			_faces = faces;
			
			_pixelShader.data.alpha.value = [ _envMapAlpha ];
			_pixelShader.data.left.input = faces[CubeFaces.LEFT];
			_pixelShader.data.right.input = faces[CubeFaces.RIGHT];
			_pixelShader.data.top.input = faces[CubeFaces.TOP];
			_pixelShader.data.bottom.input = faces[CubeFaces.BOTTOM];
			_pixelShader.data.front.input = faces[CubeFaces.FRONT];
			_pixelShader.data.back.input = faces[CubeFaces.BACK];
			_pixelShader.data.cubeDim.value = [ faces[CubeFaces.LEFT].width*.5 ];
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
			_pixelShader.data.alpha.value = [ value ];
		}
	}
}