package away3d.graphs
{
	import away3d.arcane;
	import away3d.events.IteratorEvent;

	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	use namespace arcane;

	public class VectorIterator extends EventDispatcher implements IIterator
	{
		private var _traverseIndex : int;
		private var _vector : Vector.<Object>;

		private var _asyncInProgress : Boolean;
		private var _maxTimeOut : Number;
		private var _asyncMethod : Function;
		private var _canceled : Boolean;
		private var _vectorLen : int;

		public function VectorIterator(vector : Vector.<Object>)
		{
			_vector = vector;
		}

		/**
		 * Resets the traversal for the tree.
		 *
		 * @return The root node of the tree, where traversal begins
		 */
		public function reset() : Object
		{
			if (_asyncInProgress)
				throw new Error("Cannot reset traversal while an asynchronous iteration is in progress!");
			_traverseIndex = 0;
			return _vector.length > 0? _vector[0] : null;
		}

		/**
		 * Traverses through the tree externally and returns the first newly encountered node. The order does not depend on camera position etc.
		 *
		 * @return The next unvisited node in the tree.
		 */
		public function next() : Object
		{
			if (_asyncInProgress)
				throw new Error("Cannot traverse through a tree while an asynchronous iteration is in progress!");
			
			return ++_traverseIndex < _vector.length? _vector[_traverseIndex] : null;
		}

		/**
		 * Traverses through the tree internally and applies the supplied function to each node
		 * @param function The function to be applied to each node. It must have the following signature: function someFunction(node : ITreeNode) : void.
		 */
		public function performMethod(method : Function) : void
		{
			var len : int = _vector.length;
			var i : int = -1;

			if (_asyncInProgress)
				throw new Error("An asynchronous iteration is already in progress!");

			while (++i < len) {
				method(_vector[i]);
			}
		}

		/**
		 * Traverses through the tree and applies the supplied function to each node in the tree asynchronously.
		 * The TreeIterator instance will dispatch IteratorEvent.ASYNC_ITERATION_COMPLETE when done.
		 * @param method The function to be applied to each node. It must have the following signature: function someFunction(node : ITreeNode) : void.
		 * @param maxTimeOut The maximum timeout in milliseconds.
		 */
		public function performMethodAsync(method : Function, maxTimeOut : Number = 500) : void
		{
			if (_asyncInProgress)
				throw new Error("An asynchronous iteration is already in progress!");

			_traverseIndex = 0;
			_vectorLen = _vector.length;

			if (_vectorLen == 0) {
				dispatchEvent(new IteratorEvent(IteratorEvent.ASYNC_ITERATION_COMPLETE));
				return;
			}

			_canceled = false;
			_maxTimeOut = maxTimeOut;
			_asyncInProgress = true;
			_asyncMethod = method;

			performMethodStep();
		}

		public function cancelAsyncTraversal() : void
		{
			if (!_asyncInProgress)
				throw new Error("No asynchronous iteration is in progress!");
			_canceled = true;
		}

		private function performMethodStep() : void
		{
			var startTime : int = getTimer();

			if (_canceled) {
				_asyncInProgress = false;
				dispatchEvent(new IteratorEvent(IteratorEvent.ASYNC_ITERATION_CANCELED));
				return;
			}
			else {
				dispatchEvent(new IteratorEvent(IteratorEvent.ASYNC_ITERATION_TICK));
			}

			do {
				_asyncMethod(_vector[_traverseIndex]);
			} while (++_traverseIndex < _vectorLen && getTimer() - startTime < _maxTimeOut);

			if (_traverseIndex < _vectorLen)
				setTimeout(performMethodStep, 40);
			else {
				_asyncInProgress = false;
				_asyncMethod = null;
				dispatchEvent(new IteratorEvent(IteratorEvent.ASYNC_ITERATION_COMPLETE));
			}
		}

		public function nextWith(predicate : Function) : Object
		{
			var obj : Object;

			while (obj = next())
				if (predicate(obj)) return obj;
			
			return obj;
		}

		public function resetWith(predicate : Function) : Object
		{

			if (_asyncInProgress)
				throw new Error("Cannot reset traversal while an asynchronous iteration is in progress!");
			_traverseIndex = 0;

			if (_vector.length == 0) return null;

			if (predicate(_vector[0]))
				return _vector[0];
			else
				return nextWith(predicate);
		}
	}
}