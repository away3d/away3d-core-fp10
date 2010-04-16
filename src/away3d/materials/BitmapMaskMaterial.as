package away3d.materials{
    import away3d.arcane;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    
    import flash.display.*;
    
	use namespace arcane;
	
    /**
    * Basic bitmap material
    */
    public class BitmapMaskMaterial extends BitmapMaterial
    {    	/** @private */        arcane override function renderTriangle(tri:DrawTriangle):void        {			_session = tri.source.session;			_screenCommands = tri.screenCommands;			_screenVertices = tri.screenVertices;			_screenIndices = tri.screenIndices;        				_session.renderTriangleBitmapMask(_renderBitmap, _offsetX, _offsetY, _scaling, _screenVertices, _screenIndices, tri.startIndex, tri.endIndex, smooth, repeat, _graphics);            if (debug)                _session.renderTriangleLine(0, 0x0000FF, 1, _screenVertices, _screenCommands, _screenIndices, tri.startIndex, tri.endIndex);							if(showNormals){								_nn.rotate(tri.faceVO.face.normal, tri.view.cameraVarsStore.viewTransformDictionary[tri.source]);				 				_sv0x = (tri.v0x + tri.v1x + tri.v2x) / 3;				_sv0y = (tri.v0y + tri.v1y + tri.v2y) / 3;				 				_sv1x = (_sv0x - (30*_nn.x));				_sv1y = (_sv0y - (30*_nn.y));				 				_session.renderLine(_sv0x, _sv0y, _sv1x, _sv1y, 0, 0xFF00FF, 1);			}        }        
		private var _offsetX:Number;
		private var _offsetY:Number;
		private var _scaling:Number;		private var _nn:Number3D = new Number3D();		private var _sv0x:Number;		private var _sv0y:Number;		private var _sv1x:Number;		private var _sv1y:Number;		
        public function set offsetX(value:Number):void
        {
        	_offsetX = value;
        }
        
        public function set offsetY(value:Number):void
        {
        	_offsetY = value;
        }
        
        public function set scaling(value:Number):void
        {
        	_scaling = value;
        }
        
		/**
		 * Creates a new <code>BitmapMaskMaterial</code> object.
		 * 
		 * @param	bitmap				The bitmapData object to be used as the material's texture.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function BitmapMaskMaterial(bitmap:BitmapData, init:Object = null)
        {        	super(bitmap, init);        	
            _offsetX = ini.getNumber("offsetX", 0);
            _offsetY = ini.getNumber("offsetY", 0);            _scaling = ini.getNumber("scaling", 1);
        }
    }
}