package away3d.animators
{
	import away3d.animators.data.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.utils.*;
	
	import flash.utils.*;
	
	public class BonesAnimator extends Animator
    {
        private var _channels:Array;
		private var _skinControllers:Array;
		private var _skinController:SkinController;
		private var _skinVertices:Array;
		private var _skinVerticesDirty:Boolean;
		private var _uniqueSkinVertices:Dictionary;
		private var _skinVertex:SkinVertex;
				
		private function populateVertices():void 
		{
			_skinVerticesDirty = false;
			
			for (var obj:Object in _uniqueSkinVertices) 
				_skinVertices.push(SkinVertex(obj));
		}
        protected override function updateTarget():void
        {
        	if (_target)
        		for each (var channel:Channel in _channels)
					channel.target = (_target as ObjectContainer3D).getChildByName(channel.name);
        }
		
        protected override function updateProgress(val:Number):void
        {
        	super.updateProgress(val);
			
            // ensure vertex list is populated
            if (_skinVerticesDirty)
                populateVertices();
			
        	//update channels
            for each (var channel:Channel in _channels)
                channel.update(_time, interpolate);
            
            //update skincontrollers
            for each(_skinController in _skinControllers)
				_skinController.update();
			
			//update skinvertices
            for each(_skinVertex in _skinVertices)
				_skinVertex.update();
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
			_channels = [];
			_skinControllers = [];
			_skinVertices = [];
			_uniqueSkinVertices = new Dictionary(true); 
			_skinVerticesDirty = true;
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
		 * Adds a <code>SkinController</code> and all associated <code>SkinVertex</code> objects to the animation.
		 */
        public function addSkinController(skinController:SkinController):void
        {
        	if (_skinControllers.indexOf(skinController) != -1)
        		return;
        	
			_skinControllers.push(skinController);
			
			for each (_skinVertex in skinController.skinVertices)
                _uniqueSkinVertices[_skinVertex] = 1;
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
