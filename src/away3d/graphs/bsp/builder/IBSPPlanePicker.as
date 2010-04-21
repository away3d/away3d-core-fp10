package away3d.graphs.bsp.builder
{
	import away3d.core.geom.NGon;

	import away3d.core.geom.Plane3D;

	import flash.events.IEventDispatcher;

	public interface IBSPPlanePicker extends IEventDispatcher
	{
		// this is an asynchronous method!
		function pickPlane(faces : Vector.<NGon>) : void;
		function cancel() : void;
		function get pickedPlane() : Plane3D;
		function get maxTimeOut() : int;
		function set maxTimeOut(value : int) : void;
		function get splitWeight() : Number;
		function set splitWeight(value : Number) : void;
		function get balanceWeight() : Number;
		function set balanceWeight(value : Number) : void;
		function get xzAxisWeight() : Number;
		function set xzAxisWeight(value : Number) : void;
		function get yAxisWeight() : Number;
		function set yAxisWeight(value : Number) : void;
	}
}