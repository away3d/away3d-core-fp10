package away3d.events
{
	import flash.events.Event;

	public class IteratorEvent extends Event
	{
		public static const ASYNC_ITERATION_COMPLETE : String = "asyncIterationComplete";
		public static const ASYNC_ITERATION_TICK : String = "asyncIterationTick";
		public static const ASYNC_ITERATION_CANCELED : String = "asyncIterationCanceled";

		public function IteratorEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = true)
		{
			super(type, bubbles, cancelable);
		}
	}
}