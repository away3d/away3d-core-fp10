package away3d.loaders
{
    import away3d.materials.*;
    import away3d.primitives.*;
    
    import flash.display.*;
    import flash.text.*;
 
	/**
	 * Default loader class used as a placeholder for loading 3d content
	 */
    public class LoaderCube extends Loader3D
    {
        private var side:MovieClip;
        private var cube:Cube;
        private var info:TextField;
        private var tf:TextFormat;
        private var _loaderSize:Number;
        
        /**
		 * Defines the prefix string used for loading geometry.
		 */
        public var geometryTitle:String;
        
        /**
		 * Defines the prefix string used for loading a material file.
		 */
		private var materialTitle:String;
		
        /**
		 * Defines the prefix string used for loading textures.
		 */
		private var textureTitle:String;
        
        /**
		 * Defines the prefix string used for parsing geometry.
		 */
		private var parsingTitle:String;
        
        
        /**
		 * Defines the width, height and depth of the cube. Defaults to 200.
		 */
        public function get loaderSize():Number
        {
        	return _loaderSize;
        }
    	
        public function set loaderSize(val:Number):void
        {
        	if (_loaderSize == val)
        		return;
        	
        	_loaderSize = val;
        	
        	cube.width = _loaderSize;
        	cube.depth = _loaderSize;
        	cube.height = _loaderSize;
        }
        
		/**
		 * Creates a new <code>LoaderCube</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function LoaderCube(init:Object = null) 
        {
            super(init);
            
            side = new MovieClip();
            var graphics:Graphics = side.graphics;
            graphics.lineStyle(1, 0xFFFFFF);
            graphics.drawCircle(100, 100, 100);
            info = new TextField();
            info.width = 200;
            info.height = 200;
            tf = new TextFormat();
            tf.size = 24;
            tf.color = 0x00FFFF;
            tf.bold = true;
            info.wordWrap = true;
            side.addChild(info);
            
            geometryTitle = ini.getString("geometryTitle", "Loading Geometry...");
            materialTitle = ini.getString("materialTitle", "Loading Material File...");
            textureTitle = ini.getString("textureTitle", "Loading Texture...");
            parsingTitle = ini.getString("parsingTitle", "Parsing Geometry...");
            _loaderSize = ini.getNumber("loaderSize", 200);

            addChild(cube = new Cube({material:new MovieMaterial(side, {transparent:true, smooth:true}), width:_loaderSize, height:_loaderSize, depth:_loaderSize}));
        }
		
		/**
		 * Listener function for an error event.
		 */
        protected override function notifyError():void 
        {
        	super.notifyError();
        	
        	//write message
        	if (mode == LOADING_GEOMETRY)
        		info.text = geometryTitle + "\n" + IOErrorText;
        	else if (mode == PARSING_GEOMETRY)
        		info.text = parsingTitle + "\n" + parser;
        	else if (mode == LOADING_MATERIAL_FILE)
        		info.text = materialTitle + "\n" + IOErrorText;
        	else if (mode == LOADING_TEXTURES)
        		info.text = textureTitle + "\n" + IOErrorText;
        	
        	info.setTextFormat(tf);
        	
        	//draw background
            var graphics:Graphics = side.graphics;
            graphics.beginFill(0xFF0000);
            graphics.drawRect(0, 0, 200, 200);
            graphics.endFill();
        }
		
		/**
		 * Listener function for a progress event.
		 */
        protected override function notifyProgress():void 
        {
        	super.notifyProgress();
        	
        	//write message
        	if (mode == LOADING_GEOMETRY)
        		info.text = geometryTitle + "\n" + bytesLoaded + " of " + bytesTotal + " bytes";
        	else if (mode == PARSING_GEOMETRY)
        		info.text = parsingTitle + "\n" + parser.parsedChunks + " of " + parser.totalChunks + " chunks";
        	else if (mode == LOADING_MATERIAL_FILE)
        		info.text = materialTitle + "\n" + bytesLoaded + " of " + bytesTotal + " bytes";
        	else if (mode == LOADING_TEXTURES)
        		info.text = textureTitle + "\n" + bytesLoaded + " of " + bytesTotal + " bytes";
        	
            info.setTextFormat(tf);
            
            //draw background
            if (mode == LOADING_GEOMETRY || mode == LOADING_MATERIAL_FILE || mode == LOADING_TEXTURES) {
	            var graphics:Graphics = side.graphics;
	            graphics.lineStyle(1, 0x808080);
	            graphics.drawCircle(100, 100, 100*bytesLoaded/bytesTotal);
	        }
        }
    }
}