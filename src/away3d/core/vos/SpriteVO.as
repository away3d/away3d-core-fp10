package away3d.core.vos
{
	import away3d.sprites.*;
	
	import flash.geom.*;
	import flash.display.*;
	
	public class SpriteVO extends ElementVO
	{
		private var _align:String;
		private var _rotation:Number;
        private var _cos:Number;
        private var _sin:Number;
        private var _cosw:Number;
        private var _cosh:Number;
		private var _sinw:Number;
        private var _sinh:Number;
        
        private function updateBounds():void
        {
            if (_rotation != 0) {
	            _cos = Math.cos(_rotation*Math.PI/180);
	            _sin = Math.sin(_rotation*Math.PI/180);
	            
	            _cosw = _cos/2;
	            _cosh = _cos/2;
	            _sinw = _sin/2;
	            _sinh = _sin/2;
	            
	            topleftx = - _cosw - _sinh;
	            toplefty = _sinw - _cosh;
	            toprightx = _cosw - _sinh;
	            toprighty = -_sinw - _cosh;
	            bottomleftx = -_cosw + _sinh;
	            bottomlefty = _sinw + _cosh;
	            bottomrightx = _cosw + _sinh;
	            bottomrighty = -_sinw + _cosh;
				
	            var boundsArrayx:Array = [];
	            boundsArrayx.push(topleftx);
	            boundsArrayx.push(toprightx);
	            boundsArrayx.push(bottomleftx);
	            boundsArrayx.push(bottomrightx);
	            minX = Infinity;
	            maxX = -Infinity;
	            var boundsx:int;
	            for each (boundsx in boundsArrayx) {
	            	if (minX > boundsx)
	            		minX = boundsx;
	            	if (maxX < boundsx)
	            		maxX = boundsx;
	            }
	            
	            var boundsArrayy:Array = [];
	            boundsArrayy.push(toplefty);
	            boundsArrayy.push(toprighty);
	            boundsArrayy.push(bottomlefty);
	            boundsArrayy.push(bottomrighty);
	            minY = Infinity;
	            maxY = -Infinity;
	            var boundsy:int;
	            for each (boundsy in boundsArrayy) {
	            	if (minY > boundsy)
	            		minY = boundsy;
	            	if (maxY < boundsy)
	            		maxY = boundsy;
	            }
	            
	            mapping.a = _cos;
	            mapping.b = -_sin;
	            mapping.c = _sin;
	            mapping.d = _cos;
	            mapping.tx = topleftx;
	            mapping.ty = toplefty;
            } else {
            	bottomrightx = toprightx = (bottomleftx = topleftx = -1/2) + 1;
	            bottomrighty = bottomlefty = (toprighty = toplefty = -1/2) + 1;
	            
            	minX = topleftx;
            	minY = toplefty;
            	maxX = bottomrightx;
            	maxY = bottomrighty;
	            mapping.a = mapping.d = 1;
	            mapping.c = mapping.b = 0;
	            mapping.tx = topleftx;
	            mapping.ty = toplefty;
            }
        }
        
        public var topleftx:Number;
        
        public var toplefty:Number;
        
        public var toprightx:Number;
        
        public var toprighty:Number;
        
        public var bottomleftx:Number;
        
        public var bottomlefty:Number;
        
        public var bottomrightx:Number;
        
        public var bottomrighty:Number;
        
        public var mapping:Matrix = new Matrix();
        
        public var minX:Number;
        
        public var maxX:Number;
        
        public var minY:Number;
        
        public var maxY:Number;
		
		public var width:Number;
		
		public var height:Number;
		
		public var scaling:Number;
		
		public var distanceScaling:Boolean;
		
		public var sprite3d:Sprite3D;
		
		public var depthOfField:Boolean;
		
		public var displayObject:DisplayObject;
		
		public var materials:Array = new Array();
		
		public var directions:Array = new Array();
		
		public function get align():String
        {
            return _align;
        }
		
        public function set align(value:String):void
        {
            if (_align == value)
                return;
			
            _align = value;
            
            updateBounds();
        }
        
		public function get rotation():Number
        {
            return _rotation;
        }
		
        public function set rotation(value:Number):void
        {
            if (_rotation == value)
                return;
			
            _rotation = value;
            
            updateBounds();
        }
	}
}