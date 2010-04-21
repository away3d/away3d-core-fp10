package away3d.graphs
{
	public interface IIterator
	{
		function reset() : Object;
		function next() : Object;
		function performMethod(method : Function) : void;
		function performMethodAsync(method : Function, maxTimeOut : Number = 500) : void;
		function cancelAsyncTraversal() : void;
	}
}