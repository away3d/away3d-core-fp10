package away3d.materials
{
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.lights.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	use namespace arcane;
	
	/**
	 * A diffuse texel shader material with support for multiple and directional lights
	 */
	public class DiffuseMultiPassMaterial extends MultiPassShaderMaterial
	{
		[Embed(source="../pbks/LambertMultiPassShader.pbj", mimeType="application/octet-stream")]
		private var NormalKernel : Class;
		
		[Embed(source="../pbks/LambertMultiPassDirShader.pbj", mimeType="application/octet-stream")]
		private var NormalKernelDir : Class;
		
		private var _objectLightPos : Vector3D = new Vector3D();
		private var _objectDirMatrix : Matrix3D = new Matrix3D();
		
		/**
		 * Create a DiffuseMultiPassMaterial
		 * 
		 * @param bitmap The texture to be used for the diffuse shading
		 * @param normalMap An object-space normal map
		 * @param targetModel The target mesh for which this shader is applied
		 * @param init An initialisation object
		 */
		public function DiffuseMultiPassMaterial(bitmap:BitmapData, normalMap:BitmapData, targetModel:Mesh, init:Object=null)
		{
 			super(bitmap, normalMap, new Shader(new NormalKernel()), new Shader(new NormalKernelDir()), targetModel, init);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function renderLightMap():void
        {
        	var invSceneTransform : Matrix3D = _mesh.inverseSceneTransform;
        	var scenePosition : Vector3D = _mesh.scenePosition;
        	var lightPosition : Vector3D;
        	var shaderJob : ShaderJob;
	        var i : int;
	        var diffuseStr : Number;
	        
	        _pointLightShader.data.objectScale.value = [ _mesh.scaleX, _mesh.scaleY, _mesh.scaleZ ];
	        
	        if (_points) {
	        	var point : PointLight3D;
	        	var dist : Number;
	        	var boundRadius : Number;
	        	var infinite : Boolean;
	        	
		        i = _points.length;
		        
		        boundRadius = _mesh._boundingRadius*_mesh._boundingScale;
		        
		        while (--i >= 0) {
					point = PointLight3D(_points[i]);
					diffuseStr = point.diffuse * point.brightness * .5;
		        	infinite = (point.fallOff == Number.POSITIVE_INFINITY || point.fallOff == Number.NEGATIVE_INFINITY);
		        	
		        	if (!infinite) {
			        	lightPosition = point.position;
			        	dist = 	(lightPosition.x-scenePosition.x)*(lightPosition.x-scenePosition.x) +
			        			(lightPosition.y-scenePosition.y)*(lightPosition.y-scenePosition.y) +
			        			(lightPosition.z-scenePosition.z)*(lightPosition.z-scenePosition.z);
			        }
		        	
		        	if (infinite || dist < (boundRadius+point.fallOff)*(boundRadius+point.fallOff)) {
			        	_objectLightPos = invSceneTransform.transformVector(point.position);
			        	_objectLightPos.normalize();
	        			_pointLightShader.data.lightPosition.value = [ _objectLightPos.x, _objectLightPos.y, _objectLightPos.z ];
		        		_pointLightShader.data.diffuseColor.value = [ point._red*diffuseStr, point._green*diffuseStr, point._blue*diffuseStr ];
		        		_pointLightShader.data.lightRadius.value = [ point.radius ];
					
						_pointLightShader.data.lightFalloff.value[0] = infinite? -1 : point.fallOff - point.radius;
						
			        	shaderJob = new ShaderJob(_pointLightShader, _lightMap);
			        	shaderJob.start(true);
			        }
		        }
	        }
	        
	        if (_directionals) {
	        	var directional : DirectionalLight3D;
	        	i = _directionals.length;
	        	
	        	while (--i >= 0) {
	        		directional = DirectionalLight3D(_directionals[i]);
	        		diffuseStr = directional.diffuse*.5;
	        		
					_objectLightPos = invSceneTransform.deltaTransformVector(directional.direction);
					_objectLightPos.normalize();
	        		_directionalLightShader.data.lightDirection.value = [ _objectLightPos.x, -_objectLightPos.y, _objectLightPos.z ];
	        		_directionalLightShader.data.diffuseColor.value = [ directional._red*.5, directional._green*.5, directional._blue*.5 ];
	        		shaderJob = new ShaderJob(_directionalLightShader, _lightMap);
		        	shaderJob.start(true);
	        	}
	        }
        }        
	}
}