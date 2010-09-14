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
	 * Bitmap material with per-texel diffuse (Lambert) shading.
	 */
	public class DiffusePBMaterial extends SinglePassShaderMaterial
	{
		[Embed(source="../pbks/LambertNormalMapShader.pbj", mimeType="application/octet-stream")]
		private var Kernel : Class;
		
		private var _objectLightPos : Vector3D = new Vector3D();
		
		/**
		 * Creates a new DiffusePBMaterial object.
		 * 
		 * @param bitmap The texture to be used for the diffuse shading
		 * @param normalMap An object-space normal map
		 * @param targetModel The target mesh for which this shader is applied
		 * @param init An initialisation object
		 */
		public function DiffusePBMaterial(bitmap:BitmapData, normalMap:BitmapData, targetModel:Mesh, init:Object=null)
		{
			super(bitmap, normalMap, new Shader(new Kernel()), targetModel, init);
		}
		
		override protected function updatePixelShader(source:Object3D, view:View3D):void
		{
			var invSceneTransform : Matrix3D = _mesh.inverseSceneTransform;
			var point : PointLight3D;
			var ambient : AmbientLight3D;
			var diffuseStr : Number;
			var ar : Number = 0,
				ag : Number = 0,
				ab : Number = 0;
			
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
				_pointLightShader.data.lightRadius.value = [ point.radius ];
				
				if (point.fallOff == Number.POSITIVE_INFINITY || point.fallOff == Number.NEGATIVE_INFINITY)
					_pointLightShader.data.lightFalloff.value = [ -1 ];
				else
					_pointLightShader.data.lightFalloff.value = [ point.fallOff - point.radius ];
				
				_pointLightShader.data.objectScale.value = [ _mesh.scaleX, _mesh.scaleY, _mesh.scaleZ ];
        		_pointLightShader.data.diffuseColor.value = [ point._red*diffuseStr, point._green*diffuseStr, point._blue*diffuseStr ];
        	}
        	else _pointLightShader.data.diffuseColor.value = [ 0, 0, 0 ];
		}
	}
}