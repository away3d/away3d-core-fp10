package away3d.audio.drivers
{
	import away3d.core.math.Number3D;
	
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.getTimer;
	
	
	/**
	 * The Simple pan/volume Sound3D driver will alter the pan and volume properties on the
	 * sound transform object of a regular flash.media.Sound3D representation of the sound. This
	 * is very efficient, but has the drawback that it can only reflect azimuth and distance,
	 * and will disregard elevation. You'll be able to hear whether a   
	*/
	public class SimplePanVolumeDriver extends AbstractSound3DDriver implements ISound3DDriver
	{
		private var _sound_chan:SoundChannel;
		private var _sound_tf:SoundTransform;
		
		private var _pause_position : Number;
		
		
		public function SimplePanVolumeDriver()
		{
			super();
			
			_sound_tf = new SoundTransform;
		}
		
		
		public function play() : void
		{
			var pos : Number;
			
			if (!_src)
				throw new Error('SimplePanVolumeDriver.play(): No sound source to play.');
				
			_playing = true;
			
			// Update sound transform first. This has not happened while
			// the sound was not playing, so needs to be done now.
			_updateSoundTransform();
			
			// Start playing. If paused, resume from pause position. Else,
			// start from beginning of file.
			pos = _paused? _pause_position : 0;
			_sound_chan = _src.play(pos, 0, _sound_tf);
		}
		
		
		public function pause() : void
		{
			_paused = true;
			_pause_position = _sound_chan.position;
			_sound_chan.stop();
		}
		
		
		public function stop() : void
		{
			_sound_chan.stop();
		}
		
		
		
		public override function updateReferenceVector(v:Number3D) : void
		{
			super.updateReferenceVector(v);
			
			// Only update sound transform while playing
			if (_playing)
				_updateSoundTransform();
		}
		
		
		
		private function _updateSoundTransform() : void
		{
			var r : Number;
			var r2 : Number;
			var azimuth:Number;
			
			azimuth = Math.atan2(_ref_v.x, _ref_v.z);
			if (azimuth < -1.5707963)
				azimuth = -(1.5707963 + (azimuth % 1.5707963));
			else if (azimuth > 1.5707963)
				azimuth = 1.5707963 - (azimuth % 1.5707963);
			
			// Divide by a number larger than pi/2, to make sure
			// that pan is never full +/-1.0, muting one channel
			// completely, which feels very unnatural. 
			_sound_tf.pan = (azimuth/1.7);
			
			// Offset radius so that max value for volume curve is 1,
			// (i.e. y~=1 for r=0.) Also scale according to configured
			// driver scale value.
			r = (_ref_v.modulo / _scale) + 0.28209479;
			r2 = r*r;
			
			// Volume is calculated according to the formula for
			// sound intensity, I = P / (4 * pi * r^2)
			// Avoid division by zero.
			if (r2>0) 	_sound_tf.volume = (1 / (12.566 * r2));		// 1 / 4pi * r^2
			else  		_sound_tf.volume = 1;
			
			// Alter according to user-specified volume
			_sound_tf.volume *= _mute? 0 : _volume;
			
			if (_sound_chan)
				_sound_chan.soundTransform = _sound_tf;
		}
	}
}