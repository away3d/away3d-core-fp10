package away3d.animators
{
	import away3d.animators.data.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.utils.*;
	
	public class BonesAnimator extends Animator
    {
        private var _channels:Vector.<Channel> = new Vector.<Channel>();
		
        protected override function updateTarget():void
        {
        	if (_target)
        		for each (var channel:Channel in _channels)
					channel.target = (_target as ObjectContainer3D).getChildByName(channel.name);
        }
		
        protected override function updateProgress(val:Number):void
        {
        	super.updateProgress(val);
			
        	//update channels
            for each (var channel:Channel in _channels)
                channel.update(_time, interpolate);
                
            //updateSkin();
        }
        
		/**
		 * Creates a new <code>BonesAnimator</code>
		 * 
		 * @param	target		[optional]	Defines the 3d object to which the animation is applied.
		 * @param	init		[optional]	An initialisation object for specifying default instance properties.
		 */
        public function BonesAnimator(target:Object3D = null, init:Object = null)
        {
        	super(target, init);
            Debug.trace(" + BonesAnimator");
        }
		
		/**
		 * Adds an animation channel to the animation timeline.
		 */
        public function addChannel(channel:Channel) : void
        {
        	if (_target)
        		channel.target = (_target as ObjectContainer3D).getChildByName(channel.name);
        	
			_channels.push(channel);
        }
        
		/**
		 * @inheritDoc
		 */
		public override function clone(animator:Animator = null):Animator
		{
			var bonesAnimator:BonesAnimator = (animator as BonesAnimator) || new BonesAnimator();
			super.clone(bonesAnimator);
			
			for each (var channel:Channel in _channels)
				bonesAnimator.addChannel(channel.clone());
				
			return bonesAnimator;
		}
    }
}
