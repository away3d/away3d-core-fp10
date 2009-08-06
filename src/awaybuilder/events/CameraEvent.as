package awaybuilder.events{	import awaybuilder.vo.SceneCameraVO;		import flash.events.Event;			
	public class CameraEvent extends Event	{		static public const ANIMATION_START : String = "CameraEvent.ANIMATION_START" ;		static public const ANIMATION_COMPLETE : String = "CameraEvent.ANIMATION_COMPLETE" ;				public var targetCamera : SceneCameraVO ;
		
		
		public function CameraEvent ( type : String , bubbles : Boolean = true , cancelable : Boolean = false )		{			super ( type , bubbles , cancelable ) ;		}	}}