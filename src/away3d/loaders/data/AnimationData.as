package away3d.loaders.data
{
	import away3d.animators.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	
	import flash.utils.*;
	
	/**
	 * Data class for the animation of a mesh.
	 * 
	 * @see away3d.loaders.data.MeshData
	 */
	public class AnimationData
	{	
		/**
		 * The name of the animation used as a unique reference.
		 */
		public var name:String;
		
		/**
		 * Reference to the animation object of the resulting animation.
		 */
		public var animator:Animator;
		
		/**
		 * Reference to the time the animation starts.
		 */
		public var start:Number = Infinity;
		
		/**
		 * Reference to the number of seconds the animation ends.
		 */
		public var end:Number = 0;
		
		/**
		 * String representing the animation type.
		 */
		public var animationType:String;
		
		/**
		 * Dictonary of names representing the animation channels used in skin animation.
		 */
		public var channels:Dictionary = new Dictionary(true);
		
		/**
		 * Array representing the frames used in vertex animation.
		 */
		public var frames:Array = [];
		
		/**
		 * Array representing the vertices used in vertex animation.
		 */
		public var vertices:Array = [];
		
		public function clone(object:Object3D):AnimationData
		{
			var animationData:AnimationData = object.animationLibrary.addAnimation(name);
			
    		animationData.start = start;
    		animationData.end = end;
    		animationData.animationType = animationType;
    		animationData.animator = animator.clone();
    		
    		return animationData;
		}
	}
}