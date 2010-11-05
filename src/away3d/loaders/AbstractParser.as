package away3d.loaders
{
	
	import away3d.arcane;
	import away3d.animators.data.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.loaders.data.*;
	import away3d.loaders.utils.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	use namespace arcane;
    
	 /**
	 * Dispatched when the 3d object parser completes a file parse successfully.
	 * 
	 * @eventType away3d.events.ParserEvent
	 */
	[Event(name="parseSuccess",type="away3d.events.ParserEvent")]
    			
	 /**
	 * Dispatched when the 3d object parser fails to parse a file.
	 * 
	 * @eventType away3d.events.ParserEvent
	 */
	[Event(name="parseError",type="away3d.events.ParserEvent")]
	    			
	 /**
	 * Dispatched when the 3d object parser progresses by one chunk.
	 * 
	 * @eventType away3d.events.ParserEvent
	 */
	[Event(name="parseProgress",type="away3d.events.ParserEvent")]
	
    /**
    * Abstract parsing object used as a base class for all loaders to extend from.
    */
	public class AbstractParser extends EventDispatcher
	{
		/** @private */
    	arcane var _container:Object3D;
		/** @private */
    	arcane var binary:Boolean;
		/** @private */
    	arcane var _totalChunks:int = 0;
        /** @private */
    	arcane var _parsedChunks:int = 0;
		/** @private */
    	arcane var _parsesuccess:ParserEvent;
		/** @private */
    	arcane var _parseerror:ParserEvent;
		/** @private */
    	arcane var _parseprogress:ParserEvent;
		/** @private */
    	arcane function notifyProgress():void
		{
        	_parseTime = getTimer() - _parseStart;
        	
        	if (_parseTime < parseTimeout) {
        		parseNext();
        	}else {
        		_parseStart = getTimer();
	        	
				if (!_parseprogress)
	        		_parseprogress = new ParserEvent(ParserEvent.PARSE_PROGRESS, this, container);
	        	
	        	dispatchEvent(_parseprogress);
        	}
		}
		/** @private */
    	arcane function notifySuccess():void
		{
			_broadcaster.removeEventListener(Event.ENTER_FRAME, update);
			
			if (!_parsesuccess)
        		_parsesuccess = new ParserEvent(ParserEvent.PARSE_SUCCESS, this, container);
        	
        	dispatchEvent(_parsesuccess);
		}
		/** @private */
    	arcane function notifyError():void
		{
			_broadcaster.removeEventListener(Event.ENTER_FRAME, update);
			
			if (!_parseerror)
        		_parseerror = new ParserEvent(ParserEvent.PARSE_ERROR, this, container);
        	
        	dispatchEvent(_parseerror);
		}
        /** @private */
		arcane function prepareData(data:*):void
        {
        }
        /** @private */
		arcane function parseNext():void
        {
        	notifySuccess();
        }
		
        private var _broadcaster:Sprite = new Sprite();
        private var _parseStart:int;
        private var _parseTime:int;
        private var _materials:Object;
        private var _faceMaterial:Material;
        private var _materialData:MaterialData;
        private var _faceData:FaceData;
        private var _vertex:Vertex;
        private var _uv:UV;
    	private var _face:Face;
        private var _moveVector:Vector3D = new Vector3D();
        
        private function update(event:Event):void
        {
        	parseNext();
        }
        
        /** @private */
        protected var _containers:Dictionary = new Dictionary(true);
        
		/** @private */
        protected var _containerData:ContainerData;
        
		/** @private */
		protected var _materialLibrary:MaterialLibrary;
		
		/** @private */
        protected var _geometryLibrary:GeometryLibrary;
        
        protected var _symbolLibrary:Dictionary = new Dictionary(true);
        /** @private */
        protected function getFileType():String
        {
        	return "Abstract";
        }
        
        protected function buildMaterials():void
		{
			for each (var _materialData:MaterialData in _materialLibrary)
			{
				Debug.trace(" + Build Material : "+_materialData.name);
				
				//overridden by the material property
				if (material)
					_materialData.material = material;
				
				//overridden by materials property
				if (_materialData.material)
					continue;
				
				Debug.trace(" + Material Type : "+_materialData.materialType);
				
				switch (_materialData.materialType)
				{
					case MaterialData.TEXTURE_MATERIAL:
						_materialLibrary.textureLoadRequired = true;
						break;
					case MaterialData.SHADING_MATERIAL:
						_materialData.material = new ShadingColorMaterial(null, {ambient:_materialData.ambientColor, diffuse:_materialData.diffuseColor, specular:_materialData.specularColor, shininess:_materialData.shininess});
						break;
					case MaterialData.COLOR_MATERIAL:
						_materialData.material = new ColorMaterial(_materialData.diffuseColor);
						break;
					case MaterialData.WIREFRAME_MATERIAL:
						_materialData.material = new WireColorMaterial();
						break;
				}
			}
		}
		
		protected function buildContainers(containerData:ContainerData, parent:ObjectContainer3D):void
		{
			for each (var _objectData:ObjectData in containerData.children) {
				if (_objectData is MeshData) {
					var mesh:Mesh = buildMesh(_objectData as MeshData, parent);
					_containers[_objectData.name] = mesh;
				} else if (_objectData is BoneData) {
					var _boneData:BoneData = _objectData as BoneData;
					var bone:Bone = new Bone({name:_boneData.name});
					_boneData.container = bone as ObjectContainer3D;
					
					_containers[bone.name] = bone;
					
					//ColladaMaya 3.05B
					bone.boneId = _boneData.id;
					
					bone.transform = _boneData.transform;
					
					bone.joint.transform = _boneData.jointTransform;
					
					buildContainers(_boneData, bone.joint);
					
					parent.addChild(bone);
					
				} else if (_objectData is ContainerData) {
					
					Debug.trace(" + Build Container : "+_objectData.name);
			
					var _containerData:ContainerData = _objectData as ContainerData;
					var objectContainer:ObjectContainer3D = _containerData.container = new ObjectContainer3D({name:_containerData.name});
					
					_containers[objectContainer.name] = objectContainer;
					
					objectContainer.transform = _objectData.transform;
					
					buildContainers(_containerData, objectContainer);
					
					if (centerMeshes && objectContainer.children.length) {
						//center children in container for better bounding radius calulations
						objectContainer.movePivot(_moveVector.x = (objectContainer.maxX + objectContainer.minX)/2, _moveVector.y = (objectContainer.maxY + objectContainer.minY)/2, _moveVector.z = (objectContainer.maxZ + objectContainer.minZ)/2);
						_moveVector = _objectData.transform.transformVector(_moveVector);
						objectContainer.moveTo(_moveVector.x, _moveVector.y, _moveVector.z);
					}
					
					parent.addChild(objectContainer);
					
				}
			}
		}
		
        protected function buildMesh(_meshData:MeshData, parent:ObjectContainer3D):Mesh
		{
			Debug.trace(" + Build Mesh : "+_meshData.name);
			
			var mesh:Mesh = new Mesh({name:_meshData.name});
			mesh.transform = _meshData.transform;
			mesh.bothsides = _meshData.geometry.bothsides;
			
			var _geometryData:GeometryData = _meshData.geometry;
			var geometry:Geometry = _geometryData.geometry;
			
			if (!geometry) {
				geometry = _geometryData.geometry = new Geometry();
				
				mesh.geometry = geometry;
				
								
				//overridden by the material property
				//if (!material) {
					//set materialdata for each face
					for each (var _meshMaterialData:MeshMaterialData in _geometryData.materials) {
						_materialData = _symbolLibrary[_meshMaterialData.symbol];
						_materialData.meshMaterials.push(_meshMaterialData);
						_meshMaterialData.material = _materialData.material;
						for each (var _faceListIndex:int in _meshMaterialData.faceList) {
							_faceData = _geometryData.faces[_faceListIndex] as FaceData;
							_faceData.meshMaterialData = _meshMaterialData;
						}
						
						_meshMaterialData.geometry = geometry;
						
						geometry.materialDictionary[_materialData] = _meshMaterialData;
					}
				//}
				
				
				if (_geometryData.skinVertices.length) {
					var rootBone:Bone = (_container as ObjectContainer3D).getBoneByName(_meshData.skeleton);
					
					//mesh.bone = container.getChildByName(_meshData.bone) as Bone;
					
		   			geometry.rootBone = rootBone;
		   			
		   			for each (var _skinController:SkinController in _geometryData.skinControllers)
		                _skinController.inverseTransform = parent.inverseSceneTransform;
				}
				
				//create faces from face and mesh data
				for each(_faceData in _geometryData.faces) {
					if (_faceData.meshMaterialData)
						_faceMaterial = _faceData.meshMaterialData.material;
					else
						_faceMaterial = null;
					
					_face = new Face(_geometryData.vertices[_faceData.v0],
												_geometryData.vertices[_faceData.v1],
												_geometryData.vertices[_faceData.v2],
												_faceMaterial,
												_geometryData.uvs[_faceData.uv0],
												_geometryData.uvs[_faceData.uv1],
												_geometryData.uvs[_faceData.uv2]);
					
					if (_faceData.meshMaterialData) {
						_faceData.meshMaterialData.elements.push(_face);
					} else {
						geometry.meshMaterialData.elements.push(_face);
					}
					
					_face.parent = geometry;
					
					geometry.elements.push(_face);
					
					geometry.faces.push(_face);
				}
				
				for each (_vertex in _geometryData.vertices)
					_vertex.geometry = geometry;
				
				for each (_uv in _geometryData.uvs)
					_uv.geometry = geometry;
				
				geometry.notifyGeometryChanged();
			} else {
				mesh.geometry = geometry;
			}
			
			if (centerMeshes) {
				mesh.movePivot(_moveVector.x = (_geometryData.maxX + _geometryData.minX)/2, _moveVector.y = (_geometryData.maxY + _geometryData.minY)/2, _moveVector.z = (_geometryData.maxZ + _geometryData.minZ)/2);
				_moveVector = _meshData.transform.transformVector(_moveVector);
				mesh.moveTo(_moveVector.x, _moveVector.y, _moveVector.z);
			}
			
			mesh.type = getFileType();
			
			if (parent)
				parent.addChild(mesh);
			else
				_container = mesh;
			
			return mesh;
		}
		
        /**
         * Instance of the Init object used to hold and parse default property values
         * specified by the initialiser object in the parser constructor.
         */
		protected var ini:Init;
		
		/**
		 * Defines a timeout period for file parsing (in milliseconds).
		 */
		public var parseTimeout:int;
		
    	/**
    	 * Overrides all materials in the model.
    	 */
        public var material:Material;
        
    	/**
    	 * Controls the automatic centering of geometry data in the model, improving culling and the accuracy of bounding dimension values. Defaults to false.
    	 */
        public var centerMeshes:Boolean;
        
    	/**
    	 * Overides materials in the model using name:value pairs.
    	 */
        public function get materials():Object
        {
        	return _materials;
        }
		
		public function set materials(val:Object):void
		{
			_materials = val;
			
			//organise the materials
			var _materialData:MaterialData;
            for (var name:String in _materials) {
                _materialData = _materialLibrary.addMaterial(name);
                _materialData.material = Cast.material(_materials[name]);

                //determine material type
                if (_materialData.material is BitmapMaterial)
                	_materialData.materialType = MaterialData.TEXTURE_MATERIAL;
                else if (_materialData.material is ShadingColorMaterial)
                	_materialData.materialType = MaterialData.SHADING_MATERIAL;
                else if (_materialData.material is WireframeMaterial)
                	_materialData.materialType = MaterialData.WIREFRAME_MATERIAL;
   			}
		}
		
    	/**
    	 * Returns the total number of data chunks parsed
    	 */
		public function get parsedChunks():int
		{
			return _parsedChunks;
		}
    	
    	/**
    	 * Returns the total number of data chunks available
    	 */
		public function get totalChunks():int
		{
			return _totalChunks;
		}
				
        /**
        * Retuns a materialLibrary object used for storing the parsed material objects.
        */
		public function get materialLibrary():MaterialLibrary
		{
			return _materialLibrary;
		}
		
        /**
        * Retuns a geometryLibrary object used for storing the parsed geometry data.
        */
		public function get geometryLibrary():GeometryLibrary
		{
			return _geometryLibrary;
		}
		
        /**
        * Retuns a 3d container object used for storing the parsed 3d object.
        */
		public function get container():Object3D
		{
			return _container;
		}
		
		/**
		 * Creates a new <code>AbstractParser</code> object.
		 *
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function AbstractParser(init:Object = null)
        {
        	ini = Init.parse(init);
        	
        	//setup default libs
        	_materialLibrary = new MaterialLibrary();
			_geometryLibrary = new GeometryLibrary();
        	
        	parseTimeout = ini.getNumber("parseTimeout", 40000);
        	material = ini.getMaterial("material") as Material;
        	materials = ini.getObject("materials") || {};
        	centerMeshes = ini.getBoolean("centerMeshes", false);
        }
        
		/**
         * Parses 3d file data.
         * 
		 * @param	data		The file data to be parsed. Can be in text or binary form.
		 * 
         * @return				The parsed 3d object.
         */
        public function parseGeometry(data:*):Object3D
        {
        	_broadcaster.addEventListener(Event.ENTER_FRAME, update);
        	
        	prepareData(data);
        	
        	//start parsing
        	_parseStart = getTimer();
        	parseNext();
        	
        	return container;
        }
        
		/**
		 * Default method for adding a parseSuccess event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnSuccess(listener:Function):void
        {
            addEventListener(ParserEvent.PARSE_SUCCESS, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a parseSuccess event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnSuccess(listener:Function):void
        {
            removeEventListener(ParserEvent.PARSE_SUCCESS, listener, false);
        }
		
		/**
		 * Default method for adding a parseError event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnError(listener:Function):void
        {
            addEventListener(ParserEvent.PARSE_ERROR, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a parseError event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnError(listener:Function):void
        {
            removeEventListener(ParserEvent.PARSE_ERROR, listener, false);
        }
        
		/**
		 * Default method for adding a parseProgress event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnProgress(listener:Function):void
        {
            addEventListener(ParserEvent.PARSE_PROGRESS, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a parseProgress event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnProgress(listener:Function):void
        {
            removeEventListener(ParserEvent.PARSE_PROGRESS, listener, false);
        }
	}
}