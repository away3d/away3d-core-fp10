package away3d.materials{
    import away3d.arcane;
	import away3d.core.render.*;
	import away3d.core.utils.*;
    import away3d.core.vos.*;
    
    import flash.display.*;    import flash.geom.*;
    
	use namespace arcane;
	
    /**
    * Basic bitmap material
    */
    public class BitmapMaskMaterial extends BitmapMaterial
    {    	/** @private */        arcane override function renderTriangle(priIndex:uint, viewSourceObject:ViewSourceObject, renderer:Renderer):void        {			_source = viewSourceObject.source;			_session = renderer._session;        	_view = renderer._view;			        	_startIndex = renderer.primitiveProperties[uint(priIndex*9)];        	_endIndex = renderer.primitiveProperties[uint(priIndex*9+1)];			_faceVO = renderer.primitiveElements[priIndex] as FaceVO;			_generated = renderer.primitiveGenerated[priIndex];						_screenVertices = viewSourceObject.screenVertices;			_screenIndices = viewSourceObject.screenIndices;        				_session.renderTriangleBitmapMask(_renderBitmap, _offsetX, _offsetY, _scaling, _screenVertices, _screenIndices, _startIndex, _endIndex, smooth, repeat, _graphics);            if (debug)                _session.renderTriangleLine(thickness, wireColor, wireAlpha, _screenVertices, renderer.primitiveCommands[priIndex], _screenIndices, _startIndex, _endIndex);							if(showNormals){								_nn = _view.cameraVarsStore.viewTransformDictionary[_source].deltaTransformVector(_faceVO.face.normal);								var index0:uint = viewSourceObject.screenIndices[renderer.primitiveProperties[priIndex*9]];				var index1:uint = viewSourceObject.screenIndices[renderer.primitiveProperties[priIndex*9] + 1];				var index2:uint = viewSourceObject.screenIndices[renderer.primitiveProperties[priIndex*9] + 2];				_sv0x = (viewSourceObject.screenVertices[index0*3] + viewSourceObject.screenVertices[index1*3] + viewSourceObject.screenVertices[index2*3]) / 3;				_sv0y = (viewSourceObject.screenVertices[index0*3 + 1] + viewSourceObject.screenVertices[index1*3 + 1] + viewSourceObject.screenVertices[index2*3 + 1]) / 3;				 				_sv1x = (_sv0x - (30*_nn.x));				_sv1y = (_sv0y - (30*_nn.y));				 				_session.renderLine(_sv0x, _sv0y, _sv1x, _sv1y, 0, 0xFF00FF, 1);			}        }        
		private var _offsetX:Number;
		private var _offsetY:Number;
		private var _scaling:Number;		private var _nn:Vector3D = new Vector3D();		private var _sv0x:Number;		private var _sv0y:Number;		private var _sv1x:Number;		private var _sv1y:Number;		
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