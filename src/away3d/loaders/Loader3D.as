﻿package away3d.loaders{    import away3d.arcane;    import away3d.containers.*;    import away3d.core.base.*;    import away3d.core.utils.*;    import away3d.events.*;    import away3d.loaders.data.*;    import away3d.loaders.utils.*;        import flash.events.*;    import flash.net.*;    			    use namespace arcane;    	 /**	 * Dispatched when the 3d object loader completes a file load successfully.	 * 	 * @eventType away3d.events.Loader3DEvent	 */	[Event(name="loadSuccess",type="away3d.events.Loader3DEvent")]    				 /**	 * Dispatched when the 3d object loader fails to load a file.	 * 	 * @eventType away3d.events.Loader3DEvent	 */	[Event(name="loadError",type="away3d.events.Loader3DEvent")]					 /**	 * Dispatched when the 3d object loader progresses in the laoding of a file.	 * 	 * @eventType away3d.events.Loader3DEvent	 */	[Event(name="loadProgress",type="away3d.events.Loader3DEvent")]		/**	 * Abstract loader class used as a placeholder for loading 3d content	 */    public class Loader3D extends ObjectContainer3D    {		/** @private */        arcane static function load(url:String, Parser:Class, init:Object):Loader3D        {            var ini:Init = Init.parse(init);            var loaderClass:Class = ini.getObject("loader") as Class || LoaderCube;            var loader:Loader3D = new loaderClass(ini);                        loader.loadGeometry(url, new Parser(ini) as AbstractParser);                        return loader;        }		/** @private */        arcane static function parse(data:*, Parser:Class, init:Object):Loader3D        {            var ini:Init = Init.parse(init);            var loaderClass:Class = ini.getObject("loader") as Class || LoaderCube;            var loader:Loader3D = new loaderClass(ini);                        loader.loadTextures(data, new Parser(ini) as AbstractParser);                        return loader;        }                public var parser:AbstractParser;                   private var _result:Object3D;        private var _bytesLoaded:int;        private var _bytesTotal:int;        private var _IOErrorText:String;        private var _urlloader:URLLoader;        private var _mtlLoader:URLLoader;        private var _loadQueue:TextureLoadQueue;        private var _loadsuccess:Loader3DEvent;        private var _loaderror:Loader3DEvent;		private var _loadprogress:Loader3DEvent;		        private function registerURL(object:Object3D):void        {        	if (object is ObjectContainer3D) {        		for each (var _child:Object3D in (object as ObjectContainer3D).children)        			registerURL(_child);        	} else if (object is Mesh) {        		(object as Mesh).url = url;        	}        }                private function notifyMaterialLibrary():void        {        	if (materialLibrary.mtlLoadRequired) {	        	//special case for obj files - trigger mtl load	        		        	mode = LOADING_MATERIAL_FILE;	        		        	_mtlLoader = new URLLoader();            	_mtlLoader.addEventListener(IOErrorEvent.IO_ERROR, onMtlError);            	_mtlLoader.addEventListener(ProgressEvent.PROGRESS, onMtlProgress);            	_mtlLoader.addEventListener(Event.COMPLETE, onMtlComplete);            	_mtlLoader.load(new URLRequest(mtlPath + materialLibrary.mtlFileName));        	} else if (autoLoadTextures && materialLibrary.textureLoadRequired) {        		//trigger textures load	        	materialLibrary.texturePath = texturePath;	        					var truncatedTexturePath:String;					        	mode = LOADING_TEXTURES;					        	_loadQueue = new TextureLoadQueue();								for each (var _materialData:MaterialData in materialLibrary) {					if (_materialData.materialType == MaterialData.TEXTURE_MATERIAL && !_materialData.material) {						// start by setting the path to the one specified inside the object (.dae file for example)						 truncatedTexturePath = texturePath;						 						// if our texture name has a "../" in its name...						if (_materialData.textureFileName.indexOf("../") != -1) {							var textureFileName_array:Array = _materialData.textureFileName.split("/"); // texture name as defined inside the .dae														if (truncatedTexturePath.indexOf("\\") != -1)								truncatedTexturePath = truncatedTexturePath.split("\\").join("/"); // replace backward slashes with forward slashes														var objectPath_array:Array = truncatedTexturePath.split("/"); // absolute path to our object (the .dae file for example)														if (objectPath_array[objectPath_array.length - 1] == "") objectPath_array.pop(); // if the path ends in "/", we'll remove the last element of the array since it's an empty string														// Search for matches to ".." inside the array - that will mean "go up one directory"							for (var i:int = textureFileName_array.length; i >= 0; i--) {								// For each match, remove the ".." from the texture path and remove a block (directory) from the absolute path to the object								if (textureFileName_array[i] == "..") {								   textureFileName_array.splice( i, 1 );								   objectPath_array.pop();								} 							}														// update paths with the result							_materialData.textureFileName = textureFileName_array.join("/");							truncatedTexturePath = objectPath_array.join("/") + "/";							materialLibrary.texturePath = truncatedTexturePath;						}																		var req:URLRequest = new URLRequest(truncatedTexturePath + _materialData.textureFileName);												var loader:TextureLoader = new TextureLoader();												_loadQueue.addItem(loader, req);					}				}				_loadQueue.addEventListener(IOErrorEvent.IO_ERROR, onTextureError);				_loadQueue.addEventListener(ProgressEvent.PROGRESS, onTextureProgress);				_loadQueue.addEventListener(Event.COMPLETE, onTextureComplete);				_loadQueue.start();	        } else {	        	//trigger load success	        	notifySuccess();	        }        }                /**        * Loader notification for a success event        */        protected function notifySuccess():void        {        	mode = COMPLETE;        	            ini.addForCheck();						_result = parser._container;			            _result.transform = transform;            _result.name = name;            _result.ownCanvas = ownCanvas;            _result.renderer = renderer;            _result.filters = filters.concat();            _result.blendMode = blendMode;            _result.alpha = alpha;            _result.visible = visible;            _result.mouseEnabled = mouseEnabled;            _result.useHandCursor = useHandCursor;            _result.pushback = pushback;            _result.pushfront = pushfront;            _result.screenZOffset = screenZOffset;            _result.pivotPoint = pivotPoint;            _result.extra = (extra is IClonable) ? (extra as IClonable).clone() : extra;			            if (parent != null) {                _result.parent = parent;                parent = null;            }						//register url with hierarchy			registerURL(_result);						//dispatch event			if (!_loadsuccess)				_loadsuccess = new Loader3DEvent(Loader3DEvent.LOAD_SUCCESS, this);							dispatchEvent(_loadsuccess);        }                /**        * Loader notification for any error event        */        protected function notifyError():void        {			//dispatch event			if (!_loaderror)				_loaderror = new Loader3DEvent(Loader3DEvent.LOAD_ERROR, this);						dispatchEvent(_loaderror);        }                /**        * Loader notification for any progress event        */        protected function notifyProgress():void        {        	//dispatch event			if (!_loadprogress)				_loadprogress = new Loader3DEvent(Loader3DEvent.LOAD_PROGRESS, this);						dispatchEvent(_loadprogress);        }                /**        * Automatically fired on a geometry error event.        */        private function onGeometryError(event:IOErrorEvent):void        {        	_IOErrorText = event.text;        	notifyError();        }                /**        * Automatically fired on a geometry progress event        */        private function onGeometryProgress(event:ProgressEvent):void        {        	_bytesLoaded = event.bytesLoaded;        	_bytesTotal = event.bytesTotal;        	notifyProgress();        }                /**        * Automatically fired on a geometry complete event        */        private function onGeometryComplete(event:Event):void        {        	loadTextures(_urlloader.data, parser);        }                /**        * Automatically fired on a parser error event.        */        private function onParserError(event:ParserEvent):void        {        	notifyError();        }                /**        * Automatically fired on a parser progress event        */        private function onParserProgress(event:ParserEvent):void        {        	notifyProgress();        }                /**        * Automatically fired on a parser complete event        */        private function onParserComplete(event:ParserEvent):void        {        	materialLibrary = parser.materialLibrary;        	        	notifyMaterialLibrary();        }                        /**        * Automatically fired on an mtl error event.        */        private function onMtlError(event:IOErrorEvent):void        {        	_IOErrorText = event.text;        	notifyError();        }                /**        * Automatically fired on an mtl progress event        */        private function onMtlProgress(event:ProgressEvent):void        {        	_bytesLoaded = event.bytesLoaded;        	_bytesTotal = event.bytesTotal;        	notifyProgress();        }                /**        * Automatically fired on an mtl complete event        */        private function onMtlComplete(event:Event):void        {        	materialLibrary.mtlLoadRequired = false;        	(parser as Obj).parseMtl(_mtlLoader.data);        	notifyMaterialLibrary();        }                /**        * Automatically fired on a texture error event.        *         * @see away3d.loaders.utils.TextureLoadQueue        */        private function onTextureError(event:IOErrorEvent):void        {        	_IOErrorText = event.text;        	notifyError();        	        	// appear wire material instead        	//materialLibrary.texturesLoaded(_loadQueue);        	        	// it success anyway but without material        	//notifySuccess();        }                /**        * Automatically fired on a texture progress event        *         * @see away3d.loaders.utils.TextureLoadQueue        */        private function onTextureProgress(event:ProgressEvent):void        {        	_bytesLoaded = event.bytesLoaded;        	_bytesTotal = event.bytesTotal;        	notifyProgress();        	dispatchEvent(event);        }                /**        * Automatically fired on a texture complete event        *         * @see away3d.loaders.utils.TextureLoadQueue        */        private function onTextureComplete(event:Event):void        {        	materialLibrary.texturesLoaded(_loadQueue);			            notifySuccess();        }                /**        * Constant value string representing the geometry loading mode of the 3d loader.        */		public const LOADING_GEOMETRY:String = "loading_geometry";                /**        * Constant value string representing the geometry parsing mode of the 3d loader.        */		public const PARSING_GEOMETRY:String = "parsing_geometry";		        /**        * Constant value string representing the material file loading mode of the 3d loader.        */		public const LOADING_MATERIAL_FILE:String = "loading_mateiral";		        /**        * Constant value string representing the texture loading mode of the 3d loader.        */		public const LOADING_TEXTURES:String = "loading_textures";		        /**        * Constant value string representing a completed loader mode.        */		public const COMPLETE:String = "complete";		        /**        * Returns the current loading mode of the 3d object loader.        */		public var mode:String;                /**        * Returns the the data container being used by the loaded file.        */        public var containerData:ContainerData;            	/**    	 * Defines a different path for the location of image files used as textures in the model. Defaults to the location of the loaded model file.    	 */        public var texturePath:String;            	/**    	 * Defines a different path for the location of the mtl files used as as the store for mateiral data in an obj file.    	 */        public var mtlPath:String;            	/**    	 * Controls the automatic loading of image files used as textures in the model. Defaults to true.    	 */        public var autoLoadTextures:Boolean;				/**		 * Returns a 3d object relating to the currently visible model.		 * While a file is being loaded, this takes the form of the 3d object loader placeholder.		 * The default placeholder is <code>LoaderCube</code>		 * 		 * Once the file has been loaded and is ready to view, the <code>handle</code> returns the 		 * parsed 3d object file and the placeholder object is swapped in the scenegraph tree.		 * 		 * @see	away3d.loaders.LoaderCube		 */        public function get handle():Object3D        {            return _result || this;        }                public function get bytesLoaded():int        {        	return _bytesLoaded;        }                public function get bytesTotal():int        {        	return _bytesTotal;        }                public function get IOErrorText():String        {        	return _IOErrorText;        }        		/**		 * Creates a new <code>Loader3D</code> object.		 * 		 * @param	init	[optional]	An initialisation object for specifying default instance properties.		 */        public function Loader3D(init:Object = null)         {        	super(init);        	        	texturePath = ini.getString("texturePath", "");        	mtlPath = ini.getString("mtlPath", "");        	autoLoadTextures = ini.getBoolean("autoLoadTextures", true);                        ini.removeFromCheck();        }        		/**         * Loads and parses a 3d file format.         * 		 * @param	url			The url location of the file to be loaded.		 * @param	parser		The parser class to be used on the file data once loaded.         */        public function loadGeometry(url:String, parser:AbstractParser):void        {        	mode = LOADING_GEOMETRY;        	            this.url = url;            this.parser = parser;                        _urlloader = new URLLoader();            _urlloader.dataFormat = parser.binary ? URLLoaderDataFormat.BINARY : URLLoaderDataFormat.TEXT;            _urlloader.addEventListener(IOErrorEvent.IO_ERROR, onGeometryError);            _urlloader.addEventListener(ProgressEvent.PROGRESS, onGeometryProgress);            _urlloader.addEventListener(Event.COMPLETE, onGeometryComplete);            _urlloader.load(new URLRequest(url));        	        }        		/**         * Parses 3d file data and loads any subsequent textures if required.         * 		 * @param	data		The file data to be parsed. Can be in text or binary form.		 * @param	parser		The parser class to be used on the file data.         */        public function loadTextures(data:*, parser:AbstractParser):void        {        	mode = PARSING_GEOMETRY;                        if (url) {				var pathArray:Array;								if (url.indexOf("\\") != -1) url = url.split("\\").join("/");								if(url.indexOf("/") != -1)					pathArray = url.split("/");				var path:String;				if (pathArray != null) {					//contains path separators (aka '/' or '\\')					pathArray.pop();					path = (pathArray.length > 0)? pathArray.join("/") + "/" : pathArray.join("/");				} else {					//does not contain path seporators so assume current directory					path = "./";				}	            //set texturePath to default if no texturePath detected	            if (texturePath == "" && url)					texturePath = path;	            	        	//set mtlPath to default if no mtlPath detected	            if (mtlPath == "" && url)					mtlPath = path;            }                    	//prepare data        	this.parser = parser;        	        	parser.addOnSuccess(onParserComplete);        	parser.addOnError(onParserError);        	parser.addOnProgress(onParserProgress);        	parser.parseGeometry(data);        }        		/**		 * Default method for adding a loadSuccess event listener		 * 		 * @param	listener		The listener function		 */        public function addOnSuccess(listener:Function):void        {            addEventListener(Loader3DEvent.LOAD_SUCCESS, listener, false, 0, true);        }				/**		 * Default method for removing a loadSuccess event listener		 * 		 * @param	listener		The listener function		 */        public function removeOnSuccess(listener:Function):void        {            removeEventListener(Loader3DEvent.LOAD_SUCCESS, listener, false);        }				/**		 * Default method for adding a loadError event listener		 * 		 * @param	listener		The listener function		 */        public function addOnError(listener:Function):void        {            addEventListener(Loader3DEvent.LOAD_ERROR, listener, false, 0, true);        }				/**		 * Default method for removing a loadError event listener		 * 		 * @param	listener		The listener function		 */        public function removeOnError(listener:Function):void        {            removeEventListener(Loader3DEvent.LOAD_ERROR, listener, false);        }				/**		 * Default method for adding a loadProgress event listener		 * 		 * @param	listener		The listener function		 */        public function addOnProgress(listener:Function):void        {            addEventListener(Loader3DEvent.LOAD_PROGRESS, listener, false, 0, true);        }				/**		 * Default method for removing a loadProgress event listener		 * 		 * @param	listener		The listener function		 */        public function removeOnProgress(listener:Function):void        {            removeEventListener(Loader3DEvent.LOAD_PROGRESS, listener, false);        }    }}