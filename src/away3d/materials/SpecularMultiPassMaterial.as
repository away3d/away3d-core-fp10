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
	 * A specular-only texel shader material supporting multiple lights.
	 */
	public class SpecularMultiPassMaterial extends MultiPassShaderMaterial
	{
		[Embed(source="../pbks/SpecularMultiPassShader.pbj", mimeType="application/octet-stream")]
		private var NormalKernel : Class;
		
		[Embed(source="../pbks/SpecularMultiPassSpecularShader.pbj", mimeType="application/octet-stream")]
		private var SpecularKernel : Class;
		
		[Embed(source="../pbks/SpecularMultiPassDirShader.pbj", mimeType="application/octet-stream")]
		private var NormalKernelDir : Class;
		
		[Embed(source="../pbks/SpecularMultiPassSpecularDirShader.pbj", mimeType="application/octet-stream")]
		private var SpecularKernelDir : Class;
		
		private var _objectViewPos : Vector3D = new Vector3D();
		
		private var _objectLightPos : Vector3D = new Vector3D();
		
		private var _specular : Number;
		
		private var _specularMap : BitmapData;
		
		/**
		 * Creates a SpecularMultiPassMaterial.
		 * 
		 * @param bitmap The texture to be used for the diffuse shading
		 * @param normalMap An object-space normal map
		 * @param targetModel The target mesh for which this shader is applied
		 * @param specularMap An optional specular map BitmapData, which modulates the specular reflections
		 * @param init An initialisation object
		 */
		public function SpecularMultiPassMaterial(bitmap:BitmapData, normalMap:BitmapData, targetModel:Mesh, specularMap : BitmapData = null, init:Object=null)
		{
			var shaderPt : Shader;
			var shaderDir : Shader;
			
			_specularMap = specularMap;
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
			_specular = ini.getNumber("specular", 1);
			
			_shaderBlendMode = BlendMode.SCREEN;
			_useAmbient = false;
		}
		
		/**
		 * An optional specular map BitmapData, which modulates the specular reflections
		 */
		public function get specularMap() : BitmapData
		{
			return _specularMap;
		}
		 
		public function set specularMap(value : BitmapData) : void
		{
			var shaderPt : Shader;
			var shaderDir : Shader;
			
			if (_specularMap) {
				if (value) {
					_pointLightShader.data.specularMap.input = value;
					_directionalLightShader.data.specularMap.input = value;
				}
				else {
					shaderPt = new Shader(new NormalKernel());
					shaderDir = new Shader(new NormalKernelDir());
					shaderPt.data.phongComponents.value[1] = gloss;
					shaderDir.data.phongComponents.value[1] = gloss;
					shaderPt.data.normalMap.input = _normalMap;
					shaderDir.data.normalMap.input = _normalMap;
					shaderPt.data.positionMap.input = _normalMap;
					shaderDir.data.positionMap.input = _normalMap;
					shaderPt.precisionHint = ShaderPrecision.FAST;
					shaderDir.precisionHint = ShaderPrecision.FAST;
					_pointLightShader = shaderPt;
					_directionalLightShader = shaderDir;
				}
			}
			else if (value) {
				shaderPt = new Shader(new SpecularKernel());
				shaderDir = new Shader(new SpecularKernelDir());
				shaderPt.data.phongComponents.value[1] = gloss;
				shaderDir.data.phongComponents.value[1] = gloss;
				shaderPt.data.specularMap.input = value;
				shaderDir.data.specularMap.input = value;
				shaderPt.data.normalMap.input = _normalMap;
				shaderDir.data.normalMap.input = _normalMap;
				shaderPt.data.positionMap.input = _normalMap;
				shaderDir.data.positionMap.input = _normalMap;
				shaderPt.precisionHint = ShaderPrecision.FAST;
				shaderDir.precisionHint = ShaderPrecision.FAST;
				_pointLightShader = shaderPt;
				_directionalLightShader = shaderDir;
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
			_directionalLightShader.data.phongComponents.value[1] = value;
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
			_objectViewPos = _mesh.inverseSceneTransform.transformVector(view.camera.position);
			_directionalLightShader.data.viewPos.value = _pointLightShader.data.viewPos.value = [ _objectViewPos.x, _objectViewPos.y, _objectViewPos.z ];
			super.updatePixelShader(source, view);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function renderLightMap():void
        {
        	var scenePosition : Vector3D = _mesh.scenePosition;
        	var lightPosition : Vector3D;
        	var lightDirection : Vector3D;
        	var invSceneTransform : Matrix3D = _mesh.inverseSceneTransform;
        	var shaderJob : ShaderJob;
        	
        	_pointLightShader.data.objectScale.value = [ _mesh.scaleX, _mesh.scaleY, _mesh.scaleZ ];
        	
	        if (_points) {
		        var i : int = _points.length;
		        var point : PointLight3D;
		        var boundRadius : Number;
		        var dist : Number;
		        var infinite : Boolean;
		        
		        boundRadius = _mesh._boundingRadius*_mesh._boundingScale;
		        		        
		        while (--i >= 0) {
		        	point = _points[i];
		        	
		        	infinite = (point.fallOff == Number.POSITIVE_INFINITY || point.fallOff == Number.NEGATIVE_INFINITY);
		        	
		        	if (!infinite) {
		        		lightPosition = point.position;
		        		dist = 	(lightPosition.x-scenePosition.x)*(lightPosition.x-scenePosition.x) +
		        				(lightPosition.y-scenePosition.y)*(lightPosition.y-scenePosition.y) +
		        				(lightPosition.z-scenePosition.z)*(lightPosition.z-scenePosition.z);
		        	}
		        	
		        	if (infinite || dist < (boundRadius+point.fallOff)*(boundRadius+point.fallOff)) {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
			        	_objectLightPos = invSceneTransform.transformVector(lightPosition);
	        			_pointLightShader.data.lightPosition.value = [ _objectLightPos.x, _objectLightPos.y, _objectLightPos.z ];
		        		_pointLightShader.data.specularColor.value = [ point._red, point._green, point._blue ];
		        		
		        		_pointLightShader.data.lightRadiusFalloff.value[0] = point.radius;
						_pointLightShader.data.lightRadiusFalloff.value[1] = infinite? -1 : point.fallOff - point.radius;
						
						_pointLightShader.data.phongComponents.value[0] = point.specular*point.brightness*_specular;
		
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
					
					lightDirection = directional.direction;
	        		_objectLightPos = invSceneTransform.deltaTransformVector(lightDirection);
					_objectLightPos.normalize();
	        		_directionalLightShader.data.lightDirection.value = [ _objectLightPos.x, -_objectLightPos.y, _objectLightPos.z ];
	        		_directionalLightShader.data.specularColor.value = [ directional._red, directional._green, directional._blue ];
	        		_directionalLightShader.data.phongComponents.value[0] = directional.specular*directional.brightness*_specular;
	        		shaderJob = new ShaderJob(_directionalLightShader, _lightMap);
		        	shaderJob.start(true);
	        	}
	        }
        }
	}
}