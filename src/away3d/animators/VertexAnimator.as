package away3d.animators 
{
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	
	/**
	 * @author robbateman
	 */
	public class VertexAnimator extends Animator 
	{
		private var _frames:Array;
		private var _cframe:Array;
		private var _nframe:Array;
		private var _vertices:Array;
		private var _cPosition:Number3D;
		private var _nPosition:Number3D;
		
        protected override function updateTarget():void
        {
        }
        
		public function get frames():Array
		{
			return _frames;
		}
		
		public function VertexAnimator()
		{
			super();
			Debug.trace(" + VertexAnimator");
			_frames = [];
			_vertices = [];
			constantFps = false;
		}
				
		/**
		 * @inheritDoc
		 */
        public override function update(time:Number):void
        {
        	super.update(time);
        	
        	var t:Number = (_progress*length + start);
        	var f:int = int(t*fps);
        	var fraction:Number = t*fps - f;
        	var invFraction:Number = 1 - fraction;
        	
        	if (f == _frames.length) {
        		_cframe = _nframe = _frames[f-1];
        	} else {
	        	_cframe = _frames[f];
	        	
	        	if (f == _frames.length - 1) {
	        		if (loop)
	        			_nframe = _frames[0];
	        		else
	        			_nframe = _frames[f];
	        	} else {
	        		_nframe = _frames[f+1];
	        	}
        	}
        	
        	//update vertices
        	var i:int = _vertices.length;
			if (interpolate) {
	        	while(i--) {
	        		_cPosition = _cframe[i] as Number3D;
	        		_nPosition = _nframe[i] as Number3D;
					(_vertices[i] as Vertex).setValue(_cPosition.x*invFraction + _nPosition.x*fraction, _cPosition.y*invFraction + _nPosition.y*fraction, _cPosition.z*invFraction + _nPosition.z*fraction);
	        	}
			} else {
				while(i--) {
					_cPosition = _cframe[i] as Number3D;
					(_vertices[i] as Vertex).setValue(_cPosition.x, _cPosition.y, _cPosition.z);
	        	}
        	}
		}
        
		public function addFrame(frame:Array):void
		{
			_frames.push(frame);
			_totalFrames = _frames.length;
		}
		
		public function addVertex(vertex:Vertex):void
		{
			_vertices.push(vertex);
		}
	}
}
