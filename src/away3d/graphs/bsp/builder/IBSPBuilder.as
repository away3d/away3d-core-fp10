package away3d.graphs.bsp.builder
{
	import away3d.graphs.bsp.*;

	import flash.events.IEventDispatcher;

	public interface IBSPBuilder extends IEventDispatcher
	{
		function build(source : Array) : void;
		function destroy() : void;
		function cancel() : void;
		function get tree() : BSPTree;
		function get leaves() : Vector.<BSPNode>;
		function get rootNode() : BSPNode;
		function get numNodes() : int;
		function get numSteps() : int;
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