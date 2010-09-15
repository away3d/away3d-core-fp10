package away3d.animators.data
{
    import away3d.core.base.*;
    
    import flash.geom.*;
	
    public class Channel
    {
    	private var i:uint;
    	private var _index:uint;
    	private var _length:uint;
    	private var _oldlength:uint;
    	
    	public var name:String;
        public var target:Object3D;
        
        public var type:Vector.<String> = new Vector.<String>();
		
		public var param:Vector.<Array> = new Vector.<Array>();
		public var inTangent:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>();
        public var outTangent:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>();
        
        public var times:Vector.<Number> = new Vector.<Number>();
        public var interpolations:Vector.<String> = new Vector.<String>();
		
        public function Channel(name:String):void
        {
        	this.name = name;
        }
		
		/**
		 * Updates the channel's target with the data point at the given time in seconds.
		 * 
		 * @param	time						Defines the time in seconds of the playhead of the animation.
		 * @param	interpolate		[optional]	Defines whether the animation interpolates between channel points Defaults to true.
		 */
        public function update(time:Number, interpolate:Boolean = true):void
        {	
            if (!target)
                return;
			
			i = type.length;
				
            if (time < times[0]) {
            	while (i--)
	                target[type[i]] = param[0][i];
            } else if (time > times[uint(times.length-1)]) {
            	while (i--)
	                target[type[i]] = param[uint(times.length-1)][i];
            } else {
				_index = _length = _oldlength = times.length - 1;
				
				while (_length > 1)
				{
					_oldlength = _length;
					_length >>= 1;
					
					if (times[uint(_index - _length)] > time) {
						_index -= _length;
						_length = _oldlength - _length;
					}
				}
				
				_index--;
				
				while (i--) {
					if (type[i] == "transform") {
						target.transform = param[_index][i] as Matrix3D;
					} else if (type[i] == "visibility") {
						target.visible = param[_index][i] > 0;
					} else {
						if (interpolate)
							target[type[i]] = ((time - times[_index]) * (param[uint(_index + 1)][i] as Number) + (times[uint(_index + 1)] - time) * (param[_index][i] as Number)) / (times[uint(_index + 1)] - times[_index]);
						else
							target[type[i]] = param[_index][i];
					}
				}
			}
        }
        
        public function clone():Channel
        {
        	var channel:Channel = new Channel(name);
        	
        	channel.type = type.concat();
        	channel.param = param.concat();
        	channel.inTangent = inTangent.concat();
        	channel.outTangent = outTangent.concat();
        	channel.times = times.concat();
        	channel.interpolations = interpolations.concat();
        	
        	return channel;
        }
    }
}
