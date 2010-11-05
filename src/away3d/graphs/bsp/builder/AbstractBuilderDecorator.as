package away3d.graphs.bsp.builder
{
	import away3d.graphs.bsp.*;
	import away3d.events.*;

	import flash.events.*;
	import flash.utils.*;

	internal class AbstractBuilderDecorator extends EventDispatcher implements IBSPBuilder
	{
		private var _canceled : Boolean;
		private var _numSteps : int;
		private var _wrapped : IBSPBuilder;
		private var _progressEvent : BSPBuildEvent;

		public function AbstractBuilderDecorator(wrapped : IBSPBuilder, numSteps : int)
		{
			super();
			_wrapped = wrapped;
			_numSteps = numSteps;
			_progressEvent = new BSPBuildEvent(BSPBuildEvent.BUILD_PROGRESS);
			_progressEvent.totalParts = this.numSteps;
			_wrapped.addEventListener(BSPBuildEvent.BUILD_CANCELED, propagateEvent);
			_wrapped.addEventListener(BSPBuildEvent.BUILD_WARNING, propagateEvent);
			_wrapped.addEventListener(BSPBuildEvent.BUILD_ERROR, propagateEvent);
		}

		private function propagateEvent(event : BSPBuildEvent) : void
		{
			dispatchEvent(event);
		}

		public function get tree() : BSPTree
		{
			return wrapped.tree;
		}

		protected function get wrapped() : IBSPBuilder
		{
			return _wrapped;
		}

		public function get rootNode() : BSPNode
		{
			return _wrapped.rootNode;
		}

		public function get maxTimeOut() : int
		{
			return _wrapped.maxTimeOut;
		}

		public function set maxTimeOut(value : int) : void
		{
			_wrapped.maxTimeOut = value;
		}

		public function get splitWeight() : Number
		{
			return _wrapped.splitWeight;
		}

		public function set splitWeight(value : Number) : void
		{
			_wrapped.splitWeight = value;
		}

		public function get balanceWeight() : Number
		{
			return _wrapped.balanceWeight;
		}

		public function set balanceWeight(value : Number) : void
		{
			_wrapped.balanceWeight = value;
		}

		public function get xzAxisWeight() : Number
		{
			return _wrapped.xzAxisWeight;
		}

		public function set xzAxisWeight(value : Number) : void
		{
			_wrapped.xzAxisWeight = value;
		}

		public function get yAxisWeight() : Number
		{
			return _wrapped.yAxisWeight;
		}

		public function set yAxisWeight(value : Number) : void
		{
			_wrapped.yAxisWeight = value;
		}

		public function build(source : Array) : void
		{
			_canceled = false;
			_wrapped.addEventListener(BSPBuildEvent.BUILD_PROGRESS, onBuildProgress);
			_wrapped.addEventListener(BSPBuildEvent.BUILD_COMPLETE, onBuildComplete);
			_wrapped.build(source);
		}

		public function get numSteps() : int
		{
			return wrapped.numSteps + _numSteps;
		}

		public function destroy() : void
		{
			throw new Error("destroy() is an abstract method and needs to be overridden!");
		}

		public function get leaves() : Vector.<BSPNode>
		{
			return _wrapped.leaves;
		}

		public function cancel() : void
		{
			_canceled = true;
			wrapped.cancel();
		}

		// this is not passing faces because it's expected to use the bsp tree's data instead
		// faces has become obsolete after the initial build
		protected function buildPart() : void
		{
			throw new Error("buildPart() is an abstract method and needs to be overridden");
		}

		public function get numNodes() : int
		{
			return _wrapped.numNodes;
		}

		protected function updateNextStep() : void
		{
			++_progressEvent.count;
		}

		protected function setProgressMessage(message : String) : void
		{
			_progressEvent.message = message;
		}

		protected function notifyProgress(done : int, total : int) : void
		{
			_progressEvent.percentPart = done / total;
			dispatchEvent(_progressEvent);
		}

		protected function notifyComplete() : void
		{
			dispatchEvent(new BSPBuildEvent(BSPBuildEvent.BUILD_COMPLETE));
		}

		protected function notifyCanceled() : void
		{
			dispatchEvent(new BSPBuildEvent(BSPBuildEvent.BUILD_CANCELED));
		}

		protected function get canceled() : Boolean
		{
			return _canceled;
		}

		private function onBuildProgress(event : BSPBuildEvent) : void
		{
			event.totalParts = numSteps;
			dispatchEvent(event);
		}

		private function onBuildComplete(event : BSPBuildEvent) : void
		{
			_wrapped.removeEventListener(BSPBuildEvent.BUILD_PROGRESS, onBuildProgress);
			_wrapped.removeEventListener(BSPBuildEvent.BUILD_COMPLETE, onBuildComplete);
			_progressEvent.count = wrapped.numSteps + 1;
			setTimeout(buildPart, 40);
		}
	}
}