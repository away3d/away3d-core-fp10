package away3d.materials
{
	import away3d.arcane;
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.light.DirectionalLight;
	import away3d.core.light.PointLight;
	import away3d.core.math.MatrixAway3D;
	import away3d.core.math.Number3D;
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.display.ShaderPrecision;
	
	use namespace arcane;
	
	public class PhongMultiPassMaterial extends MultiPassShaderMaterial
	{
		[Embed(source="../pbks/PhongMultiPassShader.pbj", mimeType="application/octet-stream")]
		private var NormalKernel : Class;
		
		[Embed(source="../pbks/PhongMultiPassSpecularShader.pbj", mimeType="application/octet-stream")]
		private var SpecularKernel : Class;
		
		[Embed(source="../pbks/PhongMultiPassDirShader.pbj", mimeType="application/octet-stream")]
		private var NormalKernelDir : Class;
		
		[Embed(source="../pbks/PhongMultiPassSpecularDirShader.pbj", mimeType="application/octet-stream")]
		private var SpecularKernelDir : Class;
		
		private var _objectViewPos : Number3D = new Number3D();
		
		private var _objectLightPos : Number3D = new Number3D();
		private var _objectDirMatrix : MatrixAway3D = new MatrixAway3D();
		
		public function PhongMultiPassMaterial(bitmap:BitmapData, normalMap:BitmapData, targetModel:Mesh, specularMap : BitmapData = null, init:Object=null)
		{
			var shaderPt : Shader;
			var shaderDir : Shader;
			
			if (specularMap) {
				shaderPt = new Shader(new SpecularKernel());
				shaderPt.data.specularMap.input = specularMap;
				shaderDir = new Shader(new SpecularKernelDir());
				shaderDir.data.specularMap.input = specularMap;
			}
			else {
				shaderPt = new Shader(new NormalKernel());
				shaderDir = new Shader(new NormalKernelDir());
			}
			
			super(bitmap, normalMap, shaderPt, shaderDir, targetModel, init);
			
			// increase the performance of pow, in which precision is not that important
			_pointLightShader.precisionHint = ShaderPrecision.FAST;
			_directionalLightShader.precisionHint = ShaderPrecision.FAST;
			
			gloss = ini.getNumber("gloss", 10);
			specular = ini.getNumber("specular", 1);
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
			_directionalLightShader.data.phongComponents.value[1] = value;
		}
		
		/**
		 * The strength of the specular highlight
		 */
		public function get specular() : Number
		{
			return _pointLightShader.data.phongComponents.value[0];
		}
		
		public function set specular(value : Number) : void
		{
			_pointLightShader.data.phongComponents.value[0] = value;
			_directionalLightShader.data.phongComponents.value[1] = value;
		}
		
		
		override protected function updatePixelShader(source:Object3D, view:View3D):void
		{
			var invSceneTransform : MatrixAway3D = _mesh.inverseSceneTransform;
			_objectViewPos.transform(view.camera.position, invSceneTransform);
			_directionalLightShader.data.viewPos.value = _pointLightShader.data.viewPos.value = [ _objectViewPos.x, _objectViewPos.y, _objectViewPos.z ];
			super.updatePixelShader(source, view);
		}
		
		override protected function renderLightMap():void
        {
        	var scenePosition : Number3D = _mesh.scenePosition;
        	var lightPosition : Number3D;
        	var invSceneTransform : MatrixAway3D = _mesh.inverseSceneTransform;
        	var shaderJob : ShaderJob;
        	
        	_pointLightShader.data.objectScale.value = [ _mesh.scaleX, _mesh.scaleY, _mesh.scaleZ ];
        	
	        if (_points) {
		        var i : int = _points.length;
		        var point : PointLight;
		        var boundRadius : Number;
		        var dist : Number;
		        var infinite : Boolean;
		        
		        boundRadius = _mesh._boundingRadius*_mesh._boundingScale;
		        		        
		        while (--i >= 0) {
		        	point = _points[i];
		        	
		        	infinite = (point.fallOff == Number.POSITIVE_INFINITY || point.fallOff == Number.NEGATIVE_INFINITY);
		        	
		        	if (!infinite) {
		        		lightPosition = point.light.scenePosition;
		        		dist = 	(lightPosition.x-scenePosition.x)*(lightPosition.x-scenePosition.x) +
		        				(lightPosition.y-scenePosition.y)*(lightPosition.y-scenePosition.y) +
		        				(lightPosition.z-scenePosition.z)*(lightPosition.z-scenePosition.z);
		        	}
		        	
		        	if (infinite || dist < (boundRadius+point.fallOff)*(boundRadius+point.fallOff)) {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
			        	_objectLightPos.transform(lightPosition, invSceneTransform);
	        			_pointLightShader.data.lightPosition.value = [ _objectLightPos.x, _objectLightPos.y, _objectLightPos.z ];
		        		_pointLightShader.data.diffuseColor.value = [ point.red*.5, point.green*.5, point.blue*.5 ];
		        		_pointLightShader.data.specularColor.value = [ point.red, point.green, point.blue ];
		        		
		        		_pointLightShader.data.lightRadiusFalloff.value[0] = point.radius;
					
						_pointLightShader.data.lightRadiusFalloff.value[1] = infinite? -1 : point.fallOff - point.radius;
		
			        	shaderJob = new ShaderJob(_pointLightShader, _lightMap);
			        	shaderJob.start(true);
			        }
		        }
	        }
	        
	        if (_directionals) {
	        	var directional : DirectionalLight;
	        	i = _directionals.length;
	        	
	        	while (--i >= 0) {
	        		directional = DirectionalLight(_directionals[i]);
	        		
	        		var transform : MatrixAway3D = directional.light.transform;

	        		_objectDirMatrix.multiply(invSceneTransform, directional.light.transform);
					_objectLightPos.x = -_objectDirMatrix.sxz;
					_objectLightPos.y = _objectDirMatrix.syz;
					_objectLightPos.z = -_objectDirMatrix.szz;
					_objectLightPos.normalize();
	        		_directionalLightShader.data.lightDirection.value = [ _objectLightPos.x, _objectLightPos.y, _objectLightPos.z ];
	        		_directionalLightShader.data.diffuseColor.value = [ directional.red*.5, directional.green*.5, directional.blue*.5 ];
	        		_directionalLightShader.data.specularColor.value = [ directional.red, directional.green, directional.blue ];
	        		shaderJob = new ShaderJob(_directionalLightShader, _lightMap);
		        	shaderJob.start(true);
	        	}
	        }
        }
	}
}