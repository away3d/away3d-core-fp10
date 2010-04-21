package away3d.graphs
{
	import away3d.arcane;
	import away3d.events.IteratorEvent;

	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	use namespace arcane;

	public class TreeIterator extends EventDispatcher implements IIterator
	{
		private var _traverseNode : ITreeNode;
		private var _traverseState : int;

		private static const TRAVERSE_PRE : int = 0;
		private static const TRAVERSE_IN : int = 1;
		private static const TRAVERSE_POST : int = 2;

		private var _rootNode : ITreeNode;

		private var _asyncInProgress : Boolean;
		private var _maxTimeOut : Number;
		private var _asyncMethod : Function;
		private var _canceled : Boolean;

		public function TreeIterator(rootNode : ITreeNode)
		{
			_rootNode = rootNode;
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
			
			_traverseState = TRAVERSE_PRE;
			_traverseNode = _rootNode;
			return _traverseNode;
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
			
			return traverseStep();
		}

		/**
		 * Traverses through the tree internally and applies the supplied function to each node
		 * @param function The function to be applied to each node. It must have the following signature: function someFunction(node : ITreeNode) : void.
		 */
		public function performMethod(method : Function) : void
		{
			var node : ITreeNode;

			if (_asyncInProgress)
				throw new Error("An asynchronous iteration is already in progress!");

			node = ITreeNode(reset());

			do {
				method(node);
			} while ((node = traverseStep()));
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

			reset();

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

		private function traverseStep() : ITreeNode
		{
			var left : ITreeNode;
			var right : ITreeNode;
			var parent : ITreeNode;
			var newVisited : Boolean;

			do {
				left = _traverseNode.leftChild;
				right = _traverseNode.rightChild;
				parent = _traverseNode.parent;

				switch (_traverseState) {
					case TRAVERSE_PRE:
						if (left) {
							_traverseNode = left;
							newVisited = true;
						}
						else
							_traverseState = TRAVERSE_IN;
						break;

					case TRAVERSE_IN:
						if (right) {
							_traverseNode = right;
							_traverseState = TRAVERSE_PRE;
							newVisited = true;
						}
						else
							_traverseState = TRAVERSE_POST;
						break;
				
					case TRAVERSE_POST:
						if (_traverseNode == parent.leftChild)
							_traverseState = TRAVERSE_IN;

						_traverseNode = parent;
						break;
				}

				// end of the line
				if (_traverseNode == _rootNode && _traverseState == TRAVERSE_POST) {
					return null;
				}

			} while (!newVisited);

			return _traverseNode;
		}

		private function performMethodStep() : void
		{
			var node : ITreeNode = _traverseNode;
			var startTime : int = getTimer();

			if (_canceled) {
				dispatchEvent(new IteratorEvent(IteratorEvent.ASYNC_ITERATION_CANCELED));
				_asyncInProgress = false;
				return;
			}
			else {
				dispatchEvent(new IteratorEvent(IteratorEvent.ASYNC_ITERATION_TICK));
			}

			do {
				_asyncMethod(node);
			} while ((node = traverseStep()) && getTimer() - startTime < _maxTimeOut);

			if (node)
				setTimeout(performMethodStep, 40);
			else {
				_asyncInProgress = false;
				_asyncMethod = null;
				dispatchEvent(new IteratorEvent(IteratorEvent.ASYNC_ITERATION_COMPLETE));
			}
		}
	}
}