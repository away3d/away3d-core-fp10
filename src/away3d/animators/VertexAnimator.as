package away3d.animators 
{
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	
	use namespace arcane;
	
	/**
	 * @author robbateman
	 */
	public class VertexAnimator extends Animator 
	{
		private var _frames:Array = new Array();
		private var _cframe:Array;
		private var _nframe:Array;
		private var _vertices:Array = new Array();
		private var _cPosition:Number3D;
		private var _nPosition:Number3D;
		
        protected override function updateTarget():void
        {
        }
		
        protected override function getDefaultFps():Number
		{
			return 10;
		}
		
        protected override function updateProgress(val:Number):void
        {
        	super.updateProgress(val);
        	
        	if (_currentFrame == _frames.length) {
        		_cframe = _nframe = _frames[_currentFrame-1];
        	} else {
	        	_cframe = _frames[_currentFrame];
	        	
	        	if (_currentFrame == _frames.length - 1) {
	        		if (loop)
	        			_nframe = _frames[0];
	        		else
	        			_nframe = _frames[_currentFrame];
	        	} else {
	        		_nframe = _frames[_currentFrame+1];
	        	}
        	}
        	
        	//update vertices
        	var i:int = _vertices.length;
			if (interpolate) {
	        	while(i--) {
	        		_cPosition = _cframe[i] as Number3D;
	        		_nPosition = _nframe[i] as Number3D;
					(_vertices[i] as Vertex).setValue(_cPosition.x*_invFraction + _nPosition.x*_fraction, _cPosition.y*_invFraction + _nPosition.y*_fraction, _cPosition.z*_invFraction + _nPosition.z*_fraction);
	        	}
			} else {
				while(i--) {
					_cPosition = _cframe[i] as Number3D;
					(_vertices[i] as Vertex).setValue(_cPosition.x, _cPosition.y, _cPosition.z);
	        	}
        	}
		}
        
		public function get frames():Array
		{
			return _frames;
		}
				
		/**
		 * Creates a new <code>VertexAnimator</code>
		 * 
		 * @param	target		[optional]	Defines the 3d object to which the animation is applied.
		 * @param	init		[optional]	An initialisation object for specifying default instance properties.
		 */
		public function VertexAnimator(target:Object3D = null, init:Object = null)
		{
			super(target, init);
			Debug.trace(" + VertexAnimator");
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
