package away3d.graphs.bsp.builder
{
	import away3d.events.IteratorEvent;
	import away3d.graphs.VectorIterator;
	import away3d.graphs.bsp.*;

	import flash.events.Event;
	import flash.utils.setTimeout;

	public class BSPPVSBuilder extends AbstractBuilderDecorator implements IBSPPortalProvider
	{
		private var _index : int;
		private var _pushIndex : int = 0;
		private var _newLen : int;
		private var _oneSidedPortals : Vector.<BSPPortal>;
		private var _partitionsBuilt : Boolean;
		private var _vectorIterator : VectorIterator;
		private var _loopPortal : BSPPortal;
		private var _numPropagations : int = 10;
		private var _propagationCount : int;

		public function BSPPVSBuilder(wrapped : IBSPPortalProvider)
		{
			//super(wrapped, 8);
			super(wrapped, 7);
		}

		public function get portals() : Vector.<BSPPortal>
		{
			return IBSPPortalProvider(wrapped).portals;
		}

		override protected function buildPart() : void
		{
			_index = 0;
			_newLen = portals.length << 1;
			_oneSidedPortals = new Vector.<BSPPortal>(_newLen, true);
			_pushIndex = -1;

			setProgressMessage("Linking portals to leaves");
			_vectorIterator = new VectorIterator(Vector.<Object>(portals));
			_vectorIterator.addEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onPartitionPortalsComplete);
			_vectorIterator.addEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onSourcePortalIterationTick);
			_vectorIterator.performMethodAsync(partitionPortal, maxTimeOut);
		}

		// can we merge paritionPortalStep and linkPortalStep?
		private function partitionPortal(portal : BSPPortal) : void
		{
			if (canceled) {
				_vectorIterator.cancelAsyncTraversal();
				notifyCanceled();
				return;
			}

			var parts : Vector.<BSPPortal> = portal.partition();
			var p1 : BSPPortal, p2 : BSPPortal;
			p1 = parts[0];
			p2 = parts[1];
			p1.maxTimeout = p2.maxTimeout = maxTimeOut;
			p1.createLists(_newLen);
			p2.createLists(_newLen);
			p1.frontNode.assignPortal(p1);
			p1.backNode.assignBackPortal(p1);
			p2.frontNode.assignPortal(p2);
			p2.backNode.assignBackPortal(p2);

			_oneSidedPortals[p1.index = ++_pushIndex] = p1;
			_oneSidedPortals[p2.index = ++_pushIndex] = p2;
			++_index;
		}

		private function onPartitionPortalsComplete(event : IteratorEvent) : void
		{
			_index = 0;
			_partitionsBuilt = true;
			updateNextStep();
			setProgressMessage("Building initial front lists");

			_vectorIterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onSourcePortalIterationTick);
			_vectorIterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onPartitionPortalsComplete);

			// create new iterator to target one sided portals
			_vectorIterator = new VectorIterator(Vector.<Object>(_oneSidedPortals));
			_vectorIterator.addEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onOneSidedPortalIterationTick);
			_vectorIterator.addEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onBuildInitialFrontListComplete);
			_vectorIterator.performMethodAsync(buildInitialFrontList, maxTimeOut);
		}

		private function buildInitialFrontList(portal : BSPPortal) : void
		{
			if (canceled) {
				_vectorIterator.cancelAsyncTraversal();
				notifyCanceled();
				return;
			}
			++_index;
			portal.findInitialFrontList(_oneSidedPortals);
		}

		private function onBuildInitialFrontListComplete(event : IteratorEvent) : void
		{
			_index = 0;
			updateNextStep();
			setProgressMessage("Finding neighbouring portals");
			_vectorIterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onBuildInitialFrontListComplete);
			_vectorIterator.addEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onFindNeighboursComplete);
			_vectorIterator.performMethodAsync(findNeighbours, maxTimeOut);
		}

		private function findNeighbours(portal : BSPPortal) : void
		{
			if (canceled) {
				_vectorIterator.cancelAsyncTraversal();
				notifyCanceled();
				return;
			}
			portal.findNeighbours();
			++_index;
		}

		private function onFindNeighboursComplete(event : IteratorEvent) : void
		{
			_index = 0;
			updateNextStep();
			setProgressMessage("Calculating potential visibility from neighbours");
			_vectorIterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onFindNeighboursComplete);
			_vectorIterator.addEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onCullAgainstNeighboursComplete);
			_vectorIterator.performMethodAsync(cullAgainstNeighbours, maxTimeOut);
		}

		private function cullAgainstNeighbours(portal : BSPPortal) : void
		{
			if (canceled) {
				_vectorIterator.cancelAsyncTraversal();
				notifyCanceled();
				return;
			}
			portal.removePortalsFromNeighbours(_oneSidedPortals);
			++_index;
		}

		private function onCullAgainstNeighboursComplete(event : IteratorEvent) : void
		{
			_index = 0;
			_oneSidedPortals.sort(portalSort);
			_propagationCount = 0;
			updateNextStep();
			setProgressMessage("Propagating visibility information");
			_vectorIterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onCullAgainstNeighboursComplete);
			_vectorIterator.addEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onPropagateVisibilityComplete);
			_vectorIterator.performMethodAsync(propagateVisibility, maxTimeOut);
		}

		private function propagateVisibility(portal : BSPPortal) : void
		{
			if (canceled) {
				_vectorIterator.cancelAsyncTraversal();
				notifyCanceled();
				return;
			}
			portal.propagateVisibility();
			++_index;
		}

		private function onPropagateVisibilityComplete(event : IteratorEvent) : void
		{
			_index = 0;
			_oneSidedPortals.sort(portalSort);

			if (++_propagationCount <= _numPropagations) {
				_vectorIterator.performMethodAsync(propagateVisibility, maxTimeOut);
			}
			else {
				updateNextStep();
				setProgressMessage("Deep-tracing potential visibility");
				_vectorIterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onCullAgainstNeighboursComplete);
				_vectorIterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onOneSidedPortalIterationTick);
				_loopPortal = BSPPortal(_vectorIterator.resetWith(hasFrontList));

				setTimeout(deepTraceVisListStep, 40);
			}
		}

		private function deepTraceVisListStep(event : Event = null) : void
		{
			if (canceled) {
				notifyCanceled();
				return;
			}

			if (event) {
				++_index;
				_loopPortal.removeEventListener(Event.COMPLETE, deepTraceVisListStep);
				_loopPortal = BSPPortal(_vectorIterator.nextWith(hasFrontList));
			}

			notifyProgress(_index, _oneSidedPortals.length);

			if (_loopPortal) {
				_loopPortal.addEventListener(Event.COMPLETE, deepTraceVisListStep);
				_loopPortal.findVisiblePortals(_oneSidedPortals);
			}
			else {
				// complete action
				_index = 0;
				updateNextStep();
				setProgressMessage("Assigning visibility list");

				_vectorIterator = new VectorIterator(Vector.<Object>(leaves));
				_vectorIterator.addEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onAssignVisListComplete);
				_vectorIterator.addEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onLeafIterationTick);
				_vectorIterator.performMethodAsync(assignVisList, maxTimeOut);
			}
		}

		private function hasFrontList(portal : BSPPortal) : Boolean
		{
			return portal.frontOrder > 0;
		}

		private function assignVisList(leaf : BSPNode) : void
		{
			if (canceled) {
				_vectorIterator.cancelAsyncTraversal();
				notifyCanceled();
				return;
			}
			++_index;
			leaf.processVislist(_oneSidedPortals);
		}

		private function onAssignVisListComplete(event : IteratorEvent) : void
		{
			_vectorIterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_COMPLETE, onAssignVisListComplete);
			_vectorIterator.removeEventListener(IteratorEvent.ASYNC_ITERATION_TICK, onLeafIterationTick);
			notifyComplete();
		}

		private function onSourcePortalIterationTick(event : IteratorEvent) : void
		{
			notifyProgress(_index, portals.length);
		}

		private function onOneSidedPortalIterationTick(event : IteratorEvent) : void
		{
			notifyProgress(_index, _oneSidedPortals.length);
		}

		private function onLeafIterationTick(event : IteratorEvent) : void
		{
			notifyProgress(_index, leaves.length);
		}

		/**
		 * Sort method for portal list. This is used to place portals with less potential visibility in front so it can impact the speed of those with more.
		 */
		private function portalSort(a : BSPPortal, b : BSPPortal) : Number
		{
			var fa : int = a.frontOrder;
			var fb : int = b.frontOrder;

			if (fa < fb) return -1;
			else if (fa == fb) return 0;
			else return 1;
		}
	}
}